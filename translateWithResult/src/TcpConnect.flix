
// This part shoul be in TcpConnect effect file
def handleWithTcpConnectWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - TcpConnect) + TcpConnectWithResult =
    y -> run {
        Ok(f(y))
    } with handler TcpConnect {
        def connect(ip, port, k) = 
            match TcpConnectWithResult.connect(ip, port) 
            {case Ok(ok) => k(ok) case Err(t) => Err(t)}
    }

def runWithTcpConnectWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - TcpConnect) + TcpConnectWithResult = handleWithTcpConnectWithResult(f)()


//This part should be in TcpConnectWithResult effect file
def handleWithTcpConnect(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - TcpConnectWithResult) + TcpConnect) =
    y -> let x = run {
        f(y)
    } with handler TcpConnectWithResult {
        def connect(ip, port, k) = k(Ok(TcpConnect.connect(ip, port)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!() //allegedly
    }

def runWithTcpConnect(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - TcpConnectWithResult) + TcpConnect = handleWithTcpConnect(f)()
