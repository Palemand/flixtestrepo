
// This part shoul be in TcpBind effect file
def handleWithTcpBindWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - TcpBind) + TcpBindWithResult =
    y -> run {
        Ok(f(y))
    } with handler TcpBind {
        def bind(ip, port, k) = 
            match TcpBindWithResult.bind(ip, port) 
            {case Ok(ok) => k(ok) case Err(t) => Err(t)}
    }

def runWithTcpBindWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - TcpBind) + TcpBindWithResult = handleWithTcpBindWithResult(f)()


//This part should be in TcpBindWithResult effect file
def handleWithTcpBind(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - TcpBindWithResult) + TcpBind) =
    y -> let x = run {
        f(y)
    } with handler TcpBindWithResult {
        def bind(ip, port, k) = k(Ok(TcpBind.bind(ip, port)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!() //allegedly
    }

def runWithTcpBind(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - TcpBindWithResult) + TcpBind = handleWithTcpBind(f)()
