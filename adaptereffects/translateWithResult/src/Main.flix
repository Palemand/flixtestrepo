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

def runTranslated(): Unit \ IO =
    let res = run {
        translate(somethingWithResult)()
    } with Dns.runWithIO;
    match res {
        case Ok(x) => x
        case Err(_) => println("Error after the fact")
    }

// could be written as a handler
def translate(f: (a -> b \ ef) ): (a -> b \ (ef - DnsWithResult) + Dns) =
    y -> run {
        f(y)
    } with handler DnsWithResult {
        def lookup(host, k) = {
            let x = Dns.lookup(host);
            k(Ok(x))
        }
        def lookupAll(host, k) = {
            let x = Dns.lookupAll(host);
            k(Ok(x))
        }
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
    