pub eff Retry {
    def ask(i: Int32): Option[Time.Duration] 
}

mod Retry {
    use Policy.Policy
    use Time.Duration
    ///
    /// A retry policy. Consists of a function from the current retry count to an optional duration to wait.
    ///
    pub enum Policy[ef: Eff] {
        case Policy(Int32 -> Option[Duration] \ ef)
    }
    ///
    /// A policy that never retries
    ///
    pub def noRetry(): Policy[{}] \ {} = 
        Policy(_ -> None)

    ///
    /// A policy that limits retries to a given number.
    ///
    pub def limitRetries(n: Int32): Policy[{}] \ {} =
        Policy(i -> {
            if (i < n) {Some(Time.Duration.zero())} else {None}}
        )

    ///
    /// Helper to assign various backoff functions
    ///
    def backoff(f: (Int32 -> Duration \ ef )): Policy[ef] =
        Policy(i -> {
            Some(f(i))
        })

    ///
    /// A policy that provides a constant backoff between retries. 
    ///
    pub def constantBackoff(dur: Duration): Policy[{}] = 
        backoff(_ -> dur)
    
    ///
    /// A policy that provides a capped exponential backoff between retries. 
    ///
    pub def expBackoff(cap: Time.Duration): Policy[{}] = 
        backoff(i -> {
            Order.max(Time.Duration.seconds(Int32.pow(base = i, 2)), cap)
        })
    
    ///
    /// A policy that provides an uncapped exponential backoff between retries. 
    ///
    pub def expBackoffUncapped(): Policy[{}] = 
        backoff(i -> {
            Time.Duration.seconds(Int32.pow(base = i, 2))
        })
    
    ///
    /// A policy that makes it retry untill some condition is met.
    ///
    pub def until(f: Unit -> Bool \ ef): Policy[ef] \ {} =
        Policy(_ -> {
            if (not f()) Some(Duration.zero()) else None
        })

    ///
    /// A policy that halts after a given deadline.
    ///
    pub def deadline(startTime: Int64, deadline: Duration): Policy[{Time.Clock}] =
        Policy(_ -> {
            let elapsed = Time.Clock.now() - startTime;
            if (elapsed >= Time.Duration.toMillis(deadline)) {
                None
            } else {
                Some(Time.Duration.milliseconds(0))
            }
        })

    ///
    /// Combines two policies, giving a policy that halts if either parameter halts, and otherwise waits the maximum duration.
    ///
    pub def combine(a: Policy[ef], b: Policy[ef2]): Policy[ef + ef2] = Policy(i -> {
            let (f1, f2) = match (a, b) {case (Policy(f1), Policy(f2)) => (f1, f2)};
            match (f1(i), f2(i)) {
                case (Some(r1), Some(r2)) => Some(Order.max(r1, r2))
                case _ => None
            }
        })

    ///
    /// A decorator that adds jitter to a policy. Is best used as the final modification.
    ///
    pub def addJitter(maxJitter: Duration, pol: Policy[ef]): Policy[ef + Math.Random] =
        Policy(i -> {
            let (Policy(f)) = pol;
            match f(i) {
                case None => None
                case Some(dur) => {
                    let nanoJit = Time.Duration.toNanos(maxJitter);
                    let nanoJitF64 = Int64.toFloat64(nanoJit);
                    let nanoJitter: Option[Int64] = Float64.tryToInt64(nanoJitF64 * Math.Random.randomFloat64());
                    match nanoJitter {
                        case Some(jit) => Some(dur + Time.Duration.nanoseconds(jit))
                        case None => Some(dur)
                    }
                }
            }
        })
    
    //
    // Main engine for running retry loops. Asks the retry effect what to do.
    //
    pub def retryLoop(g: e -> Bool \ ef2, f: Unit -> Result[e,b] \ ef1): Result[e, b]\ ef1 + Retry + Time.Sleep + ef2 = 
        @Tailrec
        def loop(i: Int32): Result[e, b] \ ef1 + ef2 + Retry + Time.Sleep = {
            match f() {
                case Ok(ok) => Ok(ok)
                case Err(e) => 
                    if (not g(e)) {
                        Err(e)
                    }
                    else {
                        match Retry.ask(i) {
                            case None => Err(e)
                            case Some(duration) => {
                                Time.Sleep.sleep(duration);
                                loop(i+1)
                            }
                        }
                    }
            }
        };
        loop(0)
    
    ///
    /// Method to apply directly to resultful functions, along with a policy, avoiding the Retry effect.
    ///
    pub def retry(pol: Policy[ef1], f: a -> Result[e, b] \ ef2): a -> Result[e, b] \ (ef2 - Retry) + ef1 + Time.Sleep =
        retryWhen(pol, _ -> true, f)
        

    ///
    /// Method to appliy directly to resultful functions, along with a policy and a error filter, avoiding the Retry effect.
    ///
    pub def retryWhen(pol: Policy[ef1], g: e -> Bool \ ef3, f: a -> Result[e, b] \ ef2): a -> Result[e, b] \ (ef2 + ef3 - Retry) + ef1 + Time.Sleep =
        x -> run {
            Retry.retryLoop(g, () -> f(x))
        } with Retry.handle(pol)
    ///
    /// Handler for the retry effect. Asks the given policy how to proceed.
    ///
    pub def handle(pol: Policy[ef1], f: Unit -> b \ ef2): b \ ef1 + (ef2 - Retry) =
        run {
            f()
        } with handler Retry {
            def ask(i, k) = {
                let Policy(g) = pol;
                match g(i) {
                    case None => k(None)
                    case Some(dur) => {
                        k(Some(dur))
                    }
                }
            }
        }
}