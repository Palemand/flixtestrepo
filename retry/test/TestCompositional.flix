use Assert.assertEq
@Test
def test01(): Unit \ IO = 
    let pol = Retry.retry(Retry.limitRetries(100));
    let res = run {
        pol(Net.Dns.lookup)("Somesitehere.nothing")
    } with Net.Dns.runWithIO
    with Time.Sleep.runWithIO
    with Sys.Console.runWithIO;
    println(res)

@Test
def test02(): Unit \ IO =
    let pol = Retry.retry(Retry.combine(Retry.expBackoff(), Retry.limitRetries(5)));
    let res = run {
        pol(Net.Dns.lookup)("Somesitehere.nothing")
    } with Net.Dns.runWithIO
    with Time.Sleep.runWithIO
    with Sys.Console.runWithIO;
    println(res)

@Test
def test03(): Unit \ IO =
    let pol = Retry.retry(Retry.combine(Retry.constantBackoff(5), Retry.until(() -> false)));
    let res = run {
        pol(Net.Dns.lookup)("Somesitehere.nothing")
    } with Net.Dns.runWithIO
    with Time.Sleep.runWithIO
    with Sys.Console.runWithIO;
    println(res)