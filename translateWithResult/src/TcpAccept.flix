
// This part shoul be in TcpAccept effect file
def handleWithTcpAcceptWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - TcpAccept) + TcpAcceptWithResult =
    y -> run {
        Ok(f(y))
    } with handler TcpAccept {
        def accept(server, k) = 
            match TcpAcceptWithResult.accept(server) 
            {case Ok(ok) => k(ok) case Err(t) => Err(t)}
    }

def runWithTcpAcceptWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - TcpAccept) + TcpAcceptWithResult = handleWithTcpAcceptWithResult(f)()


//This part should be in TcpAcceptWithResult effect file
def handleWithTcpAccept(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - TcpAcceptWithResult) + TcpAccept) =
    y -> let x = run {
        f(y)
    } with handler TcpAcceptWithResult {
        def accept(server, k) = k(Ok(TcpAccept.accept(server)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!()
    }

def runWithTcpAccept(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - TcpAcceptWithResult) + TcpAccept = handleWithTcpAccept(f)()
