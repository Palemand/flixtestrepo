@Test
def test01(): Unit = 
    let _ = run {
        Dns.lookup("hej")
    } with ???;
    ()


def runWithStub(f: Unit -> a \ ef): Unit = ???
