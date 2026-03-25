
def dnsHandler(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + Retry + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retryLoop(() -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(Retry.retryLoop(() -> Net.Dns.lookupAll(host)))
    }

/*
///
/// A handler for the Net.Dns effect that adds retries. 
///
def dnsHandleWithRetry[ef1: Eff, ef2: Eff, b: Type](pol: Retry.Policy[ef1], f: Unit -> b \ ef2): b \ (ef2 - Net.Dns) + ef1 + Time.Sleep + Sys.Console + Net.Dns =
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retry(pol, Net.Dns.lookup)(host))
        def lookupAll(host, k) = k(Retry.retry(pol, Net.Dns.lookupAll)(host))
    }

// this uses the retry effect
def dnsHandleWithRetry2[ef2: Eff, b: Type](f: Unit -> b \ ef2): b \ (ef2 - Net.Dns) + Net.Dns + Time.Sleep + Retry = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = {
            def loop(i: Int32): b \ (ef2 - Net.Dns) + Net.Dns + Time.Sleep + Retry = {
                match Net.Dns.lookup(host) {
                    case Ok(ip) => k(Ok(ip))
                    case Err(e) => match Retry.ask(i) {
                        case None => k(Err(e))
                        case Some(dur) => {
                            Time.Sleep.sleep(dur);
                            loop(i + 1)
                        }
                    }
                }
            };
            loop(0)
        }
        def lookupAll(_host, _k) = unreachable!()
    }

*/