def dnsHandleWithRetry[ef1: Eff, ef2: Eff, b: Type](pol: Retry.Policy[ef1], f: Unit -> b \ ef2): b \ ef2 + ef1 + Time.Sleep + Sys.Console + Net.Dns =
    run {
        f()
    } with handler Net.Dns {
        def lookup(host, k) = k(Retry.retry(pol, Net.Dns.lookup)(host))
        def lookupAll(host, k) = k(Retry.retry(pol, Net.Dns.lookupAll)(host))
    }
