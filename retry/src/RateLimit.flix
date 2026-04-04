pub eff RateLimit {
    def limit(): Unit
}

mod RateLimit {
    use Time.TimeUnit.Nanoseconds
    use Time.Duration
    
    ///
    /// A generic wrapper to trigger the effect.
    ///
    pub def limiter(f: Unit -> a \ ef): a \ ef + RateLimit =
        RateLimit.limit();
        f()
        
    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the minimum interval policy to enforce a minimum interval between requests. Given in `ims`
    ///
    pub def withMinInterval(ims: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Clock + Time.Sleep = 
        region rc {
            let lastReq = Ref.fresh(rc, 0i64);
            let imsNanos = Time.Duration.toNanos(ims);
            run {
                f()
            } with handler RateLimit {
                def limit(k) = {
                    let now = Time.Clock.currentTime(Nanoseconds);
                    let timeSinceLast = now - Ref.get(lastReq);
                    let wait = imsNanos - timeSinceLast;
                    if (wait > 0i64) {
                        Time.Sleep.sleep(Time.Duration.nanoseconds(wait))
                    };
                    Ref.put(Time.Clock.currentTime(Nanoseconds), lastReq);
                    k()
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
            let lastUpdate = Ref.fresh(rc, Time.Clock.currentTime(Nanoseconds));
            let bucket = Ref.fresh(rc, bucketSize);
            let tokenDelayNanos = Time.Duration.toNanos(tokenDelay);
            run {
                f()
            } with handler RateLimit {
                def limit(k) = {
                    let now = Time.Clock.currentTime(Nanoseconds);
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
                    k()
                }
            }
        }

    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the "Sliding Window" approach to delay requests. Sleeps till the next slot is available, then proceeds. 
    ///
    pub def withSlidingWindow(windowSize: Int32, windowDuration: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Clock + Time.Sleep =
        region rc {
            let requestTimes: MutDeque[Int64, rc] = MutDeque.empty(rc);
            let windowDurationNanos = Time.Duration.toNanos(windowDuration);
            run {
                f()
            } with handler RateLimit {
                def limit(k) = {
                    let now = Time.Clock.currentTime(Nanoseconds);
                    // Fjern forreste
                    def evict() = {
                        match MutDeque.peekFront(requestTimes) {
                            case None => ()
                            case Some(t) =>
                                if (now - t >= windowDurationNanos) {
                                    let _ = MutDeque.popFront(requestTimes);
                                    evict()
                                }
                        }
                    };    
                    evict();
                    if (MutDeque.size(requestTimes) < windowSize) {
                        MutDeque.pushBack(now, requestTimes) 
                    } else {
                        match MutDeque.peekFront(requestTimes) {
                            case None => bug!("Unexpected empty queue when full")
                            case Some(x) => {
                                let wait = windowDurationNanos - (now - x);
                                Time.Sleep.sleep(Time.Duration.nanoseconds(wait));
                                MutDeque.pushBack(Time.Clock.currentTime(Nanoseconds), requestTimes)
                            }
                        }
                    };
                    k()
                }
            }
        }

}