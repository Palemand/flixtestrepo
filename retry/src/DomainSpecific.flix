// ------------- dns
def dnsHandler(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + Retry + Time.Sleep + Net.Dns = 
    dnsConditionalHandler(_ -> true, f)

def dnsConditionalHandler(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + ef2 + Retry + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookupAll(host)))
    }

// ------------- http
def httpHandler(f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + Retry + Time.Sleep + Net.Http = 
    httpConditionalHandler(_ -> true, f)

def httpConditionalHandler(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + ef2 + Retry + Time.Sleep + Net.Http =
    run {
        f()
    } with handler Net.Http {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Http.request(req)))
    }


// ------------- https
def  httpsHandler(f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + Retry + Time.Sleep + Net.Https = 
    httpsConditionalHandler(_ -> true, f)

def httpsConditionalHandler(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + ef2 + Retry + Time.Sleep + Net.Https =
    run {
        f()
    } with handler Net.Https {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Https.request(req)))
    }
