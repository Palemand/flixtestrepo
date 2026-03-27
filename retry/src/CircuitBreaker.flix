eff CircuitBreaker {
    def ask(): Bool
    def onSuccess(): Unit
    def onError(): Unit
}
mod CircuitBreaker {
    use CircuitBreaker.State
    use Time.Duration
    
    pub enum State {
        case Closed(Int32),
        case Open(Int64), 
        case HalfOpen
    }

    /// A generic wrapper to trigger the effect.
    pub def circuitBreaker(f: Unit -> Result[IoError, t] \ ef): Result[IoError, t] \ ef + CircuitBreaker =
        if (CircuitBreaker.ask()) {
            match f() {
                case Ok(result) => 
                    CircuitBreaker.onSuccess();
                    Ok(result)
                case Err(err) => 
                    CircuitBreaker.onError();
                    Err(err)
            }
        } else {
            Err(IoError.IoError(IoError.ErrorKind.Other, "Circuit Breaker is Open"))
        }

    ///
    /// Handler for the CircuitBreaker effect.
    /// 
    pub def handle(threshhold: Int32, cd: Duration, f: Unit -> a \ ef1): a \ ef1 - CircuitBreaker + Time.Clock = 
        region rc {
            let state = Ref.fresh(rc, State.Closed(0));
            let cdNanos = Time.Duration.toNanos(cd);
            run {
                f()
            } with handler CircuitBreaker {
                def ask(k) = {
                    match Ref.get(state) {
                        case State.Closed(_) => k(true)
                        case State.Open(since) => {
                            let now = Time.Clock.currentTime(Time.TimeUnit.Nanoseconds);
                            if (now - since >= cdNanos) {
                                Ref.put(State.HalfOpen, state);
                                k(true)
                            } else {
                                k(false)
                            }
                        }
                        case State.HalfOpen => k(true)
                    }
                }
                def onError(k) = {
                    match Ref.get(state) {
                        case State.Closed(count) => {
                            Ref.put(State.Closed(count + 1), state);
                            if (count + 1 >= threshhold) {
                                Ref.put(State.Open(Time.Clock.currentTime(Time.TimeUnit.Nanoseconds)), state)
                            };
                            k()
                        }
                        case State.Open(_) => bug!("State shouldnt be open on an error")
                        case State.HalfOpen => Ref.put(State.Open(Time.Clock.currentTime(Time.TimeUnit.Nanoseconds)), state); k()  
                    }
                }
                def onSuccess(k) = {
                    Ref.put(State.Closed(0), state);
                    k()
                }
            }
        }
}