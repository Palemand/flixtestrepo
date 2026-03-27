use Time.TimeUnit.Milliseconds
use Time.Duration.nanoseconds

use Time.Duration.milliseconds
use Time.Duration.seconds
use Time.TimeUnit.Nanoseconds

/// A mock computationally/network fast task that we want to rate limit
def fastTask(id: Int32): Unit \ RateLimit + IO + Time.Clock = {
    RateLimit.limiter(() -> {
        println("  -> Executing Task #${id} at ${timeString()}");
        // Simulate that the task takes essentially 0 milliseconds
        () 
    })
}

/// Helper to print a simple time string for visual feedback
def timeString(): String \ Time.Clock = {
    let nowMs = Time.Clock.currentTime(Milliseconds);
    "${nowMs} ms"
}

/// Helper to measure and print total elapsed time
def measureTime(name: String, f: Unit -> a \ ef): Unit \ ef + IO + Time.Clock= {
    let start = Time.Clock.currentTime(Nanoseconds);
    println("--- Starting [ ${name} ] ---");
    let _ = f();
    let end = Time.Clock.currentTime(Nanoseconds);
    let elapsedMs = (end - start) / 1000000i64;
    println("--- Completed [ ${name} ] in ${elapsedMs} ms ---\n")
}

pub def runShowcase(): Unit \ IO + Time.Sleep + Time.Clock = {
    
    let requests = 1 :: 2 :: 3 :: 4 :: 5 :: 6 :: 7 :: 8 :: 9 :: 10 :: Nil;

    // ----------------------------------------------------
    // DEMO 1: MINIMUM INTERVAL
    // ----------------------------------------------------
    // We enforce strictly 100ms between calls. 
    // 5 calls = 0ms (1st), 100ms, 200ms, 300ms, 400ms. Total ~400ms.
    // measureTime("Minimum Interval: strictly 100ms spacing", () -> {
    //     run {
    //         List.forEach(fastTask, requests)
    //     } with RateLimit.withMinInterval(milliseconds(20))<
    // })
    
    // ----------------------------------------------------
    // DEMO 2: TOKEN BUCKET (Bursty)
    // ----------------------------------------------------
    // We allow an initial burst of 3, but a refill happens only every 100ms.
    // 5 calls = 
    //  - Task 1, 2, 3 happen instantly (Burst). Bucket is now empty!
    //  - Task 4 waits for 1 refill (sleeps ~100ms).
    //  - Task 5 waits for 1 refill (sleeps ~100ms). 
    // Total ~200ms.
    // measureTime("Token Bucket: Burst of 3, then 1 every 100ms", () -> {
    //     run {
    //         List.forEach(fastTask, requests)
    //     } with RateLimit.withTokenBucket(3, milliseconds(100))
    // })

    measureTime("Sliding Window: 3 requests per 100ms (2nd run)", () -> {
        run {
            List.forEach(fastTask, requests)
        } with RateLimit.withSlidingWindow(3, Time.Duration.milliseconds(100))
    })
    // circuitbreak
}
