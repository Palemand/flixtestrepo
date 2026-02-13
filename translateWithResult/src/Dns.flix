
// This part shoul be in DNS effect file


def handleWithDnsWithResult(f: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - Dns) + DnsWithResult =
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
        def lookupAll(host, k) = {
            let x = DnsWithResult.lookupAll(host);
            match x {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
    }

def runWithDnsWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - Dns) + DnsWithResult = handleWithDnsWithResult(f)()


//This part should be in DnsWithResult effect file
def handleWithDns(f: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - DnsWithResult) + Dns) =
    y -> let x = run {
        f(y)
    } with handler DnsWithResult {
        def lookup(host, k) = {
            let dnsRes = Dns.lookup(host);
            k(Ok(dnsRes))
        }
        def lookupAll(host, k) = {
            let dnsRes = Dns.lookupAll(host);
            k(Ok(dnsRes))
        }
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!()
    }

def runWithDns(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - DnsWithResult) + Dns = handleWithDns(f)()
