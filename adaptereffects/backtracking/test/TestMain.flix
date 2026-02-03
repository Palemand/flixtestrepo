use Assert.{assertEq}
@Test
def test01(): Unit \ Assert = Assert.assertEq(expected = 2, 1 + 1)

@Test
def testGetInput(): Unit \ {Assert, Abort} =
    region rc {
        let ref = Ref.fresh(rc, "2");
        run {
            assertEq(expected = 2,    getInput());
            assertEq(expected = 3,    getInput())
        } with handler Console {
            def readln(k) = {
                let val = Ref.get(ref);
                Ref.put("3", ref);
                k(val)
            }
            def print(_s, k) = ???
            def eprint(_s, k) = ???
            def println(_s, k) = k()
            def eprintln(_s, k) = ???
        }
    }