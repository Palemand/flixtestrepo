pub eff RateLimit {
    def ask(): Bool
}

mod RateLimit {
    use Time.Duration

    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the minimum interval policy to enforce a minimum interval between requests. Given in `ims`
    ///
    pub def withMinInterval(ims: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Clock + Time.Sleep = 
        region rc {
            let lastReq = Ref.fresh(rc, 0i64);
            run {
                f()
            } with handler RateLimit {
                def ask(k) = {
                    let now = Time.Clock.now();
                    let imsmillis = Time.Duration.toMillis(ims);
                    let timeSinceLast = Ref.get(lastReq) - now;
                    let wait = imsmillis - timeSinceLast;
                    if (wait > 0i64) {Time.Sleep.sleep(Time.Duration.milliseconds(Int64.clampToInt32(min = 0, max = Int32.maxValue(), wait)))}; // call to Time.Sleep eff
                    Ref.put(Time.Clock.now(), lastReq);
                    k(true)
                }
            }
        }
    ///
    /// Handler for the RateLimit effect.
    ///
    /// Uses the "Token Bucket" approach to delay requests. Sleeps till the next token is available, then consumes a token and proceeds.
    ///
    pub def withTokenBucket(bucketSize: Int32, tokenDelay: Duration, f: Unit -> a \ ef1): a \ ef1 - RateLimit + Time.Clock =
        region rc {
            let lastUpdate = Ref.fresh(rc, 0i64);
            let bucket = Ref.fresh(rc, bucketSize);
            run {
                f()
            } with handler RateLimit {
                def ask(k) = {
                    let now = Time.Clock.now();
                    let timeSinceLast = now - Ref.get(lastUpdate);
                    let newTokens = Int64.clampToInt32(min = 0, max = Int32.maxValue(), timeSinceLast / Time.Duration.toMillis(tokenDelay));
                    Ref.put(now, lastUpdate);
                    
                }
            }
        }

}