
// This part shoul be in Http effect file


def handleWithHttpWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - Http) + HttpWithResult =
    y -> run {
        Ok(f(y))
    } with handler Http {
        def request(method, url, headers, body, k) = 
            match HttpWithResult.request(method, url, headers, body)
            {case Ok(ok) => k(ok) case Err(t) => Err(t)}
    }

def runWithHttpWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - Http) + HttpWithResult = handleWithHttpWithResult(f)()



//This part should be in HttpWithResult effect file
def handleWithHttp(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - HttpWithResult) + Http) =
    y -> let x = run {
        f(y)
    } with handler HttpWithResult {
        def request(method, url, headers, body, k) = k(Ok(Http.request(method, url, headers, body)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!() //allegedly
    }

def runWithHttp(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - HttpWithResult) + Http = handleWithHttp(f)()
