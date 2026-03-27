// ------------- dns
def dnswithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + Retry + Time.Sleep + Net.Dns = 
    dnsConditionalwithRetry(_ -> true, f)

def dnsConditionalwithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + ef2 + Retry + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookupAll(host)))
    }

// ------------- http
def httpwithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + Retry + Time.Sleep + Net.Http = 
    httpConditionalwithRetry(_ -> true, f)

def httpConditionalwithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + ef2 + Retry + Time.Sleep + Net.Http =
    run {
        f()
    } with handler Net.Http {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Http.request(req)))
    }


// ------------- https
def  httpswithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + Retry + Time.Sleep + Net.Https = 
    httpsConditionalwithRetry(_ -> true, f)

def httpsConditionalwithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + ef2 + Retry + Time.Sleep + Net.Https =
    run {
        f()
    } with handler Net.Https {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Https.request(req)))
    }
