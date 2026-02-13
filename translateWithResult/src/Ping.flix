
// This part shoul be in Ping effect file


def handleWithPingWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - Ping) + PingWithResult =
    y -> run {
        Ok(f(y))
    } with handler Ping {
        def isReachable(host, timeout, u, k) = 
            match PingWithResult.isReachable(host, timeout, u) 
            {case Ok(ok) => k(ok) case Err(t) => Err(t)}
    }

def runWithPingWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - Ping) + PingWithResult = handleWithPingWithResult(f)()


//This part should be in PingWithResult effect file
def handleWithPing(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - PingWithResult) + Ping) =
    y -> let x = run {
        f(y)
    } with handler PingWithResult {
        def isReachable(host, timeout, u, k) = k(Ok(Ping.isReachable(host, timeout, u)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!()
    }

def runWithPing(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - PingWithResult) + Ping = handleWithPing(f)()
