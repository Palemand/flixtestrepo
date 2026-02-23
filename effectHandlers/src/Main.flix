
// The main entry point.
def main(): Unit \ IO =
    println("Hello World!")


def severity(): Unit \ IO =
    let _ = run {
        Logger.fatal("fatal");
        Logger.warn("warn");
        Logger.info("info");
        Set.empty()
    } with runWithSeverityFilter(Set#{Severity.Fatal, Severity.Warn})
    with Logger.runWithIO;
    ()


//husk `RichString.checkEqual` i stedet
instance Eq[RichString] {
    pub def eq(x: RichString, y: RichString): Bool = checkEqual(x, y)
}
