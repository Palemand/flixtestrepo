use Severity.{Fatal, Warn, Info, Trace}
use Assert.{assertEq}

@Test
def testRunWithSeverityFilter01(): Unit \ Assert =
    let res: String = run {
        Logger.info("info");
        "ignored"
    } with runWithSeverityFilter(Set#{Fatal})
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    };
    assertEq(expected = "ignored", res)

@Test
def testRunWithSeverityFilter02(): Unit \ Assert =
    let res: String = run {
        Logger.fatal("fatal");
        "ignored"
    } with runWithSeverityFilter(Set#{Fatal})
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    };
    assertEq(expected = "fatal", res)


@Test
def testRunWithSeverityFilter03(): Unit \ Assert =
    let res: Set[String] = run {
        Logger.fatal("fatal");
        Logger.warn("warn");
        Logger.info("info");
        Set.empty()
    } with runWithSeverityFilter(Set#{Fatal, Warn})
    with handler Logger {
        def log(_s, m, k) = Set.union(k(), Set#{RichString.toString(m)})
    };
    assertEq(expected = Set#{"fatal", "warn"}, res)


@Test
def testRunWithSeverityFilter201(): Unit \ Assert =
    let res: String = run {
        Logger.info("info");
        "ignored"
    } with runWithSeverityFilter2((_msg, _sev) -> true)
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    };
    assertEq(expected = "info", res)

@Test
def testRunWithSeverityFilter202(): Unit \ Assert =
    let res: String = run {
        Logger.info("info");
        "ignored"
    } with runWithSeverityFilter2((_msg, sev) -> Set.exists(a -> a == sev, Set#{Severity.Fatal}))
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    };
    assertEq(expected = "ignored", res)

@Test
def testRunWithSeverityFilter203(): Unit \ Assert =
    let res: String = run {
        Logger.info("info");
        "ignored"
    } with runWithSeverityFilter2((msg, sev) -> if (Set.exists(a -> a == sev, Set#{Severity.Fatal})) true else {
        Console.println(RichString.toString(msg)); false})
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    } with handler Console {
        def readln(_k) = unreachable!()
        def print(_s, _k) = unreachable!()
        def eprint(_s, _k) = unreachable!()
        def println(s, _k) = {s}
        def eprintln(_s, _k) = unreachable!()
    };
    assertEq(expected = "info", res)


@Test
def testRunWithSeverityFilter204(): Unit \ Assert =
    let res: String = run {
        Logger.info("info");
        "ignored"
    } with runWithSeverityFilter2(onlyLevels(Set#{Warn, Fatal}))
    with handler Logger {
        def log(_s, m, _k) = RichString.toString(m)
    };
    assertEq(expected = "ignored", res)