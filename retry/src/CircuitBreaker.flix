eff CircuitBreaker {
    def trial(): Bool
    def error(): Unit
}
mod CircuitBreaker {
    use CircuitBreaker.State
    use Time.Duration

    enum State {
        case Closed(Int32),
        case Open(Int64), 
        case HalfOpen
    }

    /// A generic wrapper to trigger the effect.
    pub def circuitBreaker(f: Unit -> Result[e, t] \ ef): Option[Result[e, t]] \ ef + CircuitBreaker =
        if (CircuitBreaker.trial()) {
            Some(f())
        } else {
            None
        }

    ///
    /// Handler for the CircuitBreaker effect.
    /// 
    pub def handle(threshhold: Int32, cd: Duration, f: Unit -> a \ ef1): a \ ef1 - CircuitBreaker = 
        region rc {
            let state = Ref.fresh(rc, State.Closed(0));
            let cdNanos = Time.Duration.toNanos(cd);
            run {
                f()
            } with handler CircuitBreaker {
                def trial(k) = {
                    match Ref.get(state) {
                        case State.Closed(count) => 
                            if (count >= threshhold) {
                                Ref.put(State.Open(cdNanos), state);
                                k(false)
                            } else {
                                Ref.put(State.Closed(count + 1), state);
                                k(true)
                            }
                        case State.Open(openTs) => ???
                        case State.HalfOpen => ???
                    }
                }
                def error(k) = {
                    ???
                }
            }
        }
}