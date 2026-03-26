pub eff RateLimit {
    def ask(): Bool
}

mod RateLimit {
    use Time.TimeUnit.Nanoseconds
    use Time.Duration

    /// A generic wrapper to trigger the effect.
    pub def limit(f: Unit -> a \ ef): Option[a] \ ef + RateLimit =
        if (RateLimit.ask()) {
            Some(f())
        } else {
            None
        }

    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the minimum interval policy to enforce a minimum interval between requests. Given in `ims`
    ///
    pub def withMinInterval(ims: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Clock + Time.Sleep + IO = 
        region rc {
            let lastReq = Ref.fresh(rc, 0i64);
            let imsNanos = Time.Duration.toNanos(ims);
            println("Minimum interval set to ${imsNanos} nanoseconds");
            run {
                f()
            } with handler RateLimit {
                def ask(k) = {
                    let now = Time.Clock.currentTime(Nanoseconds);
                    let timeSinceLast = now - Ref.get(lastReq);
                    let wait = imsNanos - timeSinceLast;
                    println("Time since last request: ${timeSinceLast}ns, need to wait: ${wait}ns");
                    if (wait > 0i64) {
                        Time.Sleep.sleep(Time.Duration.nanoseconds(wait))
                    };
                    Ref.put(Time.Clock.currentTime(Nanoseconds), lastReq);
                    k(true)
                }
            }
        }
    
    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the "Token Bucket" approach to delay requests. Sleeps till the next token is available, then consumes a token and proceeds.
    ///
    pub def withTokenBucket(bucketSize: Int32, tokenDelay: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Sleep + Time.Clock =
        region rc {
            let lastUpdate = Ref.fresh(rc, Time.Clock.now());
            let bucket = Ref.fresh(rc, bucketSize);
            let tokenDelayNanos = Time.Duration.toNanos(tokenDelay);
            run {
                f()
            } with handler RateLimit {
                def ask(k) = {
                    let now = Time.Clock.now();
                    let timeSinceLast = now - Ref.get(lastUpdate);
                    let newTokens = Int64.clampToInt32(min = 0, max = Int32.maxValue(), timeSinceLast / tokenDelayNanos);
                    if (newTokens > 0) {
                        Ref.put(Int32.min(bucketSize, Ref.get(bucket) + newTokens), bucket);
                        Ref.put(Ref.get(lastUpdate) + (Int32.toInt64(newTokens) * tokenDelayNanos), lastUpdate)
                    };
                    if (Ref.get(bucket) > 0) {
                        Ref.put(Ref.get(bucket) - 1, bucket)
                    } else {
                        let wait = tokenDelayNanos - (now - Ref.get(lastUpdate));
                        Time.Sleep.sleep(Time.Duration.nanoseconds(wait));
                        Ref.put(Ref.get(lastUpdate) + tokenDelayNanos, lastUpdate)
                    };
                    k(true)   
                }
            }
        }

    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the "Sliding Window" approach to delay requests. Sleeps till the next slot is available, then proceeds. 
    ///
    pub def withSlidingWindow(windowSize: Int32, windowDuration: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Sleep + Time.Clock =
        region rc {
            ???
        }

}