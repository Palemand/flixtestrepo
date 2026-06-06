eff MyPrint {
    def println(x: String): Unit
}

def runShallow(do: String -> Unit \ ef2, f: Unit -> a \ ef): a \ ef + ef2 + MyPrint =
    region rc {
        let rf = Ref.fresh(rc, false);
        run {
            f()
        } with handler MyPrint {
            def println(x, k) = 
                match Ref.get(rf) {
                    case false => 
                        Ref.put(true, rf);
                        do(x);
                        k()
                    case true =>
                        MyPrint.println(x);
                        k()
                }
        }
    }

def abortIfRecieve(f: Unit -> a \ ef): a \ ef - MyPrint + Abort =
    run {
        f()
    } with handler MyPrint {
        def println(_x, _k) = Abort.abort(RichString.fromString("Too many calls to MyPrint"))
    }

def main(): Result[RichString, Unit] \ IO = 
    run {
        MyPrint.println("Hello,");
        MyPrint.println("world!");
        MyPrint.println("My");
        MyPrint.println("name is");
        MyPrint.println("computa");
        MyPrint.println("I will abort!")
    } 
    with runShallow(println)
    with runShallow(Logger.info)
    with runShallow(Logger.trace)
    with runShallow(Logger.fatal)
    with runShallow(Logger.warn)
    with Logger.runWithIO
    with abortIfRecieve
    with Abort.runWithResult
