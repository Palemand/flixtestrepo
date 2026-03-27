// ------------- dns
def dnsWithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + Retry + Time.Sleep + Net.Dns = 
    dnsConditionalWithRetry(_ -> true, f)

def dnsConditionalWithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + ef2 + Retry + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(Retry.retryLoop(g, () -> Net.Dns.lookupAll(host)))
    }

def dnsWithRateLimit(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + RateLimit + Time.Clock + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(RateLimit.limiter(() -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(RateLimit.limiter(() -> Net.Dns.lookupAll(host)))
    }

def dnsWithCircuitBreaker(f: Unit -> b \ ef1): b \ (ef1 - Net.Dns) + CircuitBreaker + Time.Sleep + Net.Dns = 
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(CircuitBreaker.circuitBreaker(() -> Net.Dns.lookup(host)))
        def lookupAll(host, k) = k(CircuitBreaker.circuitBreaker(() -> Net.Dns.lookupAll(host)))
    }

// ------------- http
def httpWithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + Retry + Time.Sleep + Net.Http = 
    httpConditionalWithRetry(_ -> true, f)

def httpConditionalWithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + ef2 + Retry + Time.Sleep + Net.Http =
    run {
        f()
    } with handler Net.Http {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Http.request(req)))
    }

def httpWithRateLimit(f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + RateLimit + Time.Clock + Time.Sleep + Net.Http = 
    run {
        f()
    } with handler Net.Http {
        def request(req, k) = k(RateLimit.limiter(() -> Net.Http.request(req)))
    }

def httpWithCircuitBreaker(f: Unit -> b \ ef1): b \ (ef1 - Net.Http) + CircuitBreaker + Time.Sleep + Net.Http = 
    run {
        f()
    } with handler Net.Http {
        def request(req, k) = k(CircuitBreaker.circuitBreaker(() -> Net.Http.request(req)))
    }


// ------------- https
def  httpsWithRetry(f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + Retry + Time.Sleep + Net.Https = 
    httpsConditionalWithRetry(_ -> true, f)

def httpsConditionalWithRetry(g: IoError -> Bool \ ef2, f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + ef2 + Retry + Time.Sleep + Net.Https =
    run {
        f()
    } with handler Net.Https {
        def request(req, k) = k(Retry.retryLoop(g, () -> Net.Https.request(req)))
    }

def httpsWithRateLimit(f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + RateLimit + Time.Clock + Time.Sleep + Net.Https = 
    run {
        f()
    } with handler Net.Https {
        def request(req, k) = k(RateLimit.limiter(() -> Net.Https.request(req)))
    }

def httpsWithCircuitBreaker(f: Unit -> b \ ef1): b \ (ef1 - Net.Https) + CircuitBreaker + Time.Sleep + Net.Https = 
    run {
        f()
    } with handler Net.Https {
        def request(req, k) = k(CircuitBreaker.circuitBreaker(() -> Net.Https.request(req)))
    }