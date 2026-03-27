use Time.Duration.milliseconds
use Time.TimeUnit.Milliseconds

/// Simple section header for readable output.
def section(name: String): Unit \ IO =
    println("");
    println("====================================================");
    println(name);
    println("====================================================")

/// Measure and print elapsed wall-clock time for a computation.
def timed(name: String, f: Unit -> a \ ef): a \ ef + IO + Time.Clock =
    let start = Time.Clock.currentTime(Milliseconds);
    println("-- ${name} --");
    let out = f();
    let stop = Time.Clock.currentTime(Milliseconds);
    println("-- completed in ${stop - start} ms --");
    out

/// Lightweight result printer that avoids depending on success payload type.
def printResult(tag: String, r: Result[IoError, a]): Unit \ IO =
    match r {
        case Ok(_) => println("${tag}: Ok")
        case Err(e) => println("${tag}: Err(${e})")
    }

/// A task that always fails with IoError, useful for deterministic demos.
def alwaysFail(name: String): Result[IoError, Unit] =
    Err(IoError.IoError(IoError.ErrorKind.Other, "simulated failure: ${name}"))

/// A task that always succeeds.
def alwaysOk(_name: String): Result[IoError, Unit] =
    Ok(())

/// A tiny operation that goes through the RateLimit effect.
def rateLimitedTick(name: String): Result[IoError, Unit] \ IO + RateLimit =
    RateLimit.limiter(() -> {
        println("tick(${name})");
        alwaysOk(name)
    })

/// ------------------------------------------------------------
/// RETRY DEMOS
/// ------------------------------------------------------------

/// Retry with a strict upper bound.
def demoRetryLimitRetries(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 1: Retry.limitRetries");
    let policy = Retry.limitRetries(3);
    let retrying = Retry.retry(policy, alwaysFail);
    let result = timed("always-fail with max 3 retries", () ->
        retrying("limit-retries")
    );
    printResult("Final", result)
}

/// Retry with backoff + deadline composed.
def demoRetryBackoffDeadline(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 2: Retry.combine(backoff, deadline)");
    let started = Time.Clock.now();
    let policy = Retry.combine(
        Retry.constantBackoff(milliseconds(120)),
        Retry.deadline(started, milliseconds(850))
    );
    let retrying = Retry.retry(policy, alwaysFail);
    let result = timed("always-fail with backoff+deadline", () ->
        retrying("backoff-deadline")
    );
    printResult("Final", result)
}

/// Retry with jitter to spread retries.
def demoRetryWithJitter(): Unit \ IO + Time.Clock + Time.Sleep + Math.Random = {
    section("DEMO 3: Retry.addJitter");
    let base = Retry.constantBackoff(milliseconds(100));
    let jittered = Retry.addJitter(milliseconds(60), base);
    let policy = Retry.combine(jittered, Retry.limitRetries(4));
    let retrying = Retry.retry(policy, alwaysFail);
    let result = timed("always-fail with jitter", () ->
        retrying("jitter")
    );
    printResult("Final", result)
}

/// ------------------------------------------------------------
/// RATE LIMIT DEMOS
/// ------------------------------------------------------------

/// Minimum interval spacing demo.
def demoRateLimitMinInterval(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 4: RateLimit.withMinInterval");
    let _ = timed("5 ticks, min interval = 200ms", () -> {
        run {
            let r1 = rateLimitedTick("mi-1");
            let r2 = rateLimitedTick("mi-2");
            let r3 = rateLimitedTick("mi-3");
            let r4 = rateLimitedTick("mi-4");
            let r5 = rateLimitedTick("mi-5");
            printResult("mi-1", r1);
            printResult("mi-2", r2);
            printResult("mi-3", r3);
            printResult("mi-4", r4);
            printResult("mi-5", r5)
        } with RateLimit.withMinInterval(milliseconds(200))
    });
    ()
}

/// Token bucket demo.
def demoRateLimitTokenBucket(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 5: RateLimit.withTokenBucket");
    let _ = timed("6 ticks, bucket=2, refill=250ms", () -> {
        run {
            let r1 = rateLimitedTick("tb-1");
            let r2 = rateLimitedTick("tb-2");
            let r3 = rateLimitedTick("tb-3");
            let r4 = rateLimitedTick("tb-4");
            let r5 = rateLimitedTick("tb-5");
            let r6 = rateLimitedTick("tb-6");
            printResult("tb-1", r1);
            printResult("tb-2", r2);
            printResult("tb-3", r3);
            printResult("tb-4", r4);
            printResult("tb-5", r5);
            printResult("tb-6", r6)
        } with RateLimit.withTokenBucket(2, milliseconds(250))
    });
    ()
}

/// Sliding window demo.
def demoRateLimitSlidingWindow(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 6: RateLimit.withSlidingWindow");
    let _ = timed("7 ticks, max 3 per 500ms", () -> {
        run {
            let r1 = rateLimitedTick("sw-1");
            let r2 = rateLimitedTick("sw-2");
            let r3 = rateLimitedTick("sw-3");
            let r4 = rateLimitedTick("sw-4");
            let r5 = rateLimitedTick("sw-5");
            let r6 = rateLimitedTick("sw-6");
            let r7 = rateLimitedTick("sw-7");
            printResult("sw-1", r1);
            printResult("sw-2", r2);
            printResult("sw-3", r3);
            printResult("sw-4", r4);
            printResult("sw-5", r5);
            printResult("sw-6", r6);
            printResult("sw-7", r7)
        } with RateLimit.withSlidingWindow(3, milliseconds(500))
    });
    ()
}

/// ------------------------------------------------------------
/// CIRCUIT BREAKER DEMOS
/// ------------------------------------------------------------

/// Demonstrate breaker opening after repeated failures.
def demoCircuitBreakerOpen(): Unit \ IO + Time.Clock = {
    section("DEMO 7: CircuitBreaker opening");
    let _ = timed("4 calls through breaker, threshold=2", () -> {
        run {
            let c1 = CircuitBreaker.circuitBreaker(() -> alwaysFail("cb-1"));
            let c2 = CircuitBreaker.circuitBreaker(() -> alwaysFail("cb-2"));
            let c3 = CircuitBreaker.circuitBreaker(() -> alwaysFail("cb-3"));
            let c4 = CircuitBreaker.circuitBreaker(() -> alwaysFail("cb-4"));
            printResult("call1", c1);
            printResult("call2", c2);
            printResult("call3", c3);
            printResult("call4", c4)
        } with CircuitBreaker.handle(2, milliseconds(1200))
    });
    ()
}

/// Demonstrate half-open recovery with a successful probe.
def demoCircuitBreakerRecovery(): Unit \ IO + Time.Clock + Time.Sleep = {
    section("DEMO 8: CircuitBreaker half-open recovery");
    run {
        let first = CircuitBreaker.circuitBreaker(() -> alwaysFail("first"));
        let second = CircuitBreaker.circuitBreaker(() -> alwaysFail("second"));
        printResult("first", first);
        printResult("second", second);

        println("sleeping 1s to pass cooldown...");
        Time.Sleep.sleep(milliseconds(1000));

        let probe = CircuitBreaker.circuitBreaker(() -> alwaysOk("probe"));
        printResult("probe", probe)
    } with CircuitBreaker.handle(1, milliseconds(900))
}

/// ------------------------------------------------------------
/// COMBINED DEMO
/// ------------------------------------------------------------

/// Combined stack: retry + breaker + rate limit.
def demoCombinedStack(): Unit \ IO + Time.Clock + Time.Sleep + Math.Random = {
    section("DEMO 9: Combined stack");
    let policy = Retry.combine(
        Retry.addJitter(milliseconds(40), Retry.constantBackoff(milliseconds(90))),
        Retry.limitRetries(2)
    );
    let retrying = Retry.retry(policy, alwaysFail);

    let _ = timed("6 combined calls, token bucket shaping", () -> {
        run {
            let call = n -> RateLimit.limiter(() ->
                run {
                    CircuitBreaker.circuitBreaker(() -> retrying("combined-${n}"))
                } with CircuitBreaker.handle(3, milliseconds(1000))
            );

            let r1 = call(1);
            let r2 = call(2);
            let r3 = call(3);
            let r4 = call(4);
            let r5 = call(5);
            let r6 = call(6);
            printResult("combined-1", r1);
            printResult("combined-2", r2);
            printResult("combined-3", r3);
            printResult("combined-4", r4);
            printResult("combined-5", r5);
            printResult("combined-6", r6)
        } with RateLimit.withTokenBucket(2, milliseconds(250))
    });
    ()
}

/// Public entry point.
pub def runShowcase(): Unit \ IO + Time.Clock + Time.Sleep + Math.Random = {
    section("FLIX RESILIENCE SHOWCASE");
    println("Showing retry, rate limiting, circuit breaker, and composition.");

    demoRetryLimitRetries();
    demoRetryBackoffDeadline();
    demoRetryWithJitter();
    demoRateLimitMinInterval();
    demoRateLimitTokenBucket();
    demoRateLimitSlidingWindow();
    demoCircuitBreakerOpen();
    demoCircuitBreakerRecovery();
    demoCombinedStack();

    section("SHOWCASE COMPLETE")
}

def main(): Unit \ IO + Time.Clock + Time.Sleep + Math.Random =
    runShowcase()