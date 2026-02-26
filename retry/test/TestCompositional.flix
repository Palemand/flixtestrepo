use Assert.assertEq
@Test
def test01(): Unit \ IO = 
    let pol = Retry.retry(Retry.limitRetries(100));
    let res = run {
        pol(DnsWithResult.lookup)("jsdtlgkjdæglkjasrg.drlgkjdrkgj")
    } with DnsWithResult.runWithIO
    with Clock.runWithIO
    with Console.runWithIO;
    println(res); ()

@Test
def test02(): Unit \ IO =
    let pol = Retry.retry(Retry.combine(Retry.expBackoff(), Retry.limitRetries(5)));
    let res = run {
        pol(DnsWithResult.lookup)("jsdtlgkjdæglkjasrg.drlgkjdrkgj")
    } with DnsWithResult.runWithIO
    with Clock.runWithIO
    with Console.runWithIO;
    println(res); ()

@Test
def test03(): Unit \ IO =
    let pol = Retry.retry(Retry.combine(Retry.constantBackoff(5), Retry.until(() -> true)));
    let res = run {
        pol(DnsWithResult.lookup)("jsdtlgkjdæglkjasrg.drlgkjdrkgj")
    } with DnsWithResult.runWithIO
    with Clock.runWithIO
    with Console.runWithIO;
    println(res); ()


// Stub helper handler
def runWithStub(f: Unit -> a \ ef ): a \ ef - Dns = 
    run {
        f()
    } with handler Dns {
        def lookup(_host, k) = {
            let optIpStub = IpAddr.fromString("0.0.0.0") |> (a -> match a {case Some(x) => x case None => unreachable!()});
            k(optIpStub)
        }
        def lookupAll(_host, _k) = unreachable!()
    }
