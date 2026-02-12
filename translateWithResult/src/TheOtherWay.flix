use IoError.IoError

//Hmmmm
/* def lol(): Unit \ IO = {
    let res = run {
        translate(translateOther(translate(somethingWithResult)))()
    } with Dns.runWithIO;
    match res {
        case Ok(_x) => ()
        case Err(_t) => ()
    }
} */

def runWithResultNormal(): Unit \ IO = {
    run {
        somethingWithResult()
    } with DnsWithResult.runWithIO
}

def runWithResultTranslated(): Unit \ IO = {
    let _ = run {
        translateOther(somethingWithoutResult)()
    } with DnsWithResult.runWithIO;
    ()
}

def translateOther(f: (a -> b \ ef)): (a -> Result[IoError, b] \ (ef - Dns) + DnsWithResult) =
    y -> run {
        Ok(f(y))
    } with handler Dns {
        def lookup(host, k) = {
            let x = DnsWithResult.lookup(host);
            match x {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def lookupAll(host, k) = ???
    }

/* def somethingWithoutResult2(): Unit \ Dns + IO =
    let res = Dns.lookup("nellemannthorsen.dk");
    println(res) */



// THIS HERE IS THE IMPORTANT ONE
def awawd(): Unit \ IO = 
    let x = run {(run {
        Dns.lookup("nellemannthorsen.dk")
    } with translateOther)()}
    with DnsWithResult.runWithIO;
    println(x)