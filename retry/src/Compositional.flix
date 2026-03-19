mod Retry {
    use Retry.Policy
    use Policy.Policy
    use Time.Duration

    pub enum Policy[ef: Eff] {
        case Policy(Int32 -> Option[Duration] \ ef)
    }

    pub def limitRetries(n: Int32): Policy[{}] \ {} =
        Policy(i -> {
            if (i < n) {Some(Time.Duration.zero())} else {None}}
        )
    
    def backoff(f: (Int32 -> Duration \ ef )): Policy[ef] =
        Policy(i -> {
            Some(f(i))
        })

    pub def constantBackoff(dur: Duration): Policy[{}] = 
        backoff(_ -> dur)
    pub def expBackoff(): Policy[{}] = 
        backoff(i -> {
            Time.Duration.seconds(Int32.pow(base = i, 2))
        })
    
    pub def until(f: Unit -> Bool \ ef): Policy[ef] \ {} =
        Policy(_i -> {
            if (not f()) Some(Duration.zero()) else None
        })

    pub def combine(a: Policy[ef], b: Policy[ef2]): Policy[ef + ef2] = Policy(i -> {
            let (f1, f2) = match (a, b) {case (Policy(f1), Policy(f2)) => (f1, f2)};
            match (f1(i), f2(i)) {
                case (Some(r1), Some(r2)) => Some(Order.max(r1, r2))
                case _ => None
            }
        })

    pub def deadline(startTime: Int64, deadline: Duration): Policy[{Time.Clock}] =
        Policy(_ -> {
            let elapsed = Time.Clock.now() - startTime;
            if (elapsed >= Time.Duration.toMillis(deadline)) {
                None
            } else {
                Some(Time.Duration.milliseconds(0))
            }
        })
    
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

    pub def retry[ef1: Eff, a: Type, b: Type, e: Type, ef2: Eff]
    (pol: Policy[ef1], f: a -> Result[e, b] \ ef2): a -> Result[e, b] \ ef1 + ef2 + Time.Sleep + Sys.Console = 
        retryRec(pol, 0, f)
    
    def retryRec[ef1: Eff, a: Type, b: Type, e: Type, ef2: Eff]
    (pol: Policy[ef1], i: Int32, f: a -> Result[e, b] \ ef2): a -> Result[e, b] \ ef1 + ef2 + Time.Sleep + Sys.Console = 
        x -> {
            let res = f(x);
            match res {
                case Ok(ok) => Ok(ok)
                case Err(e) => { match pol {case Policy(g) => {
                    match g(i) {
                        case None => Err(e)
                        case Some(dur) => {
                            //todo: Remove print
                            Sys.Console.println("Waiting now " + ToString.toString(Time.Duration.toNanos(dur)) + " nanoseconds before retrying..."); 
                            Time.Sleep.sleep(dur);
                            retryRec(pol, i + 1, f, x) //tailrec?
                        }
                    }
                }}
                }
            }
        }
}