// The main entry point.
def main(): Unit \ IO =
    println("hej")


def runStandardNoResult(): Unit \ IO =
    let res = run {
        somethingWithoutResult()
    } with Dns.runWithIO;
    match res {
        case Ok(x) => x
        case Err(_) => println("Error after the fact")
    }

def runStandard(): Unit \ IO =
    run {
        somethingWithResult()
    } with DnsWithResult.runWithIO

/* def runTranslated(): Unit \ IO =
    let res = run {
        translate(somethingWithResult)()
    } with Dns.runWithIO;
    match res {
        case Ok(x) => x
        case Err(_) => println("Error after the fact")
    } */

// could be written as a handler
def translate(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - DnsWithResult) + Dns) =
    y -> let x = run {
        f(y)
    } with handler DnsWithResult {
        def lookup(host, k) = {
            let dnsRes = Dns.lookup(host);
            k(Ok(dnsRes))
        }
        def lookupAll(host, k) = ???
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!() //allegedly
    }




def somethingWithoutResult(): Unit \ Dns + IO =
    let res = Dns.lookup("nellemannthorsen.dk");
    println(res)

def somethingWithResult(): Unit \ {DnsWithResult, IO} =
    let res = DnsWithResult.lookup("nellemannthorsen.dk");
    match res {
        case Ok(x) => println(x)
        case Err(_x) => println("Error")
    }




// its working
def ftlhjkfltkh(): Unit \ IO = 
    let res = run {
        let x = translate(translateOther(translate(translateOther(translate(DnsWithResult.lookup)))))("nellemannthorsen.dk");
        x
    } with Dns.runWithIO;
    println(res)


def stubDNs(): Unit \IO =
    let stubIPOpt = IpAddr.fromString("0.0.0.0");
    let stubIp = match stubIPOpt {
            case Some(x) => x
            case None => unreachable!()
    };

    let res: Result[IoError, IpAddr] = run {
        let dnsRes = Dns.lookup("?host");
        Ok(dnsRes)
    } with handler Dns {
        def lookup(host, k) = k(stubIp)
        def lookupAll(host, k) = ???
    };
    println(res)