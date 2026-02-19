use Assert.{assertEq}

@Test
def testRunWithChain01(): Unit \ Assert =
    let (_, list) = run {
        Logger.fatal("A fatal error has occured")
    } with runWithList;
    let expected = List#{(Severity.Fatal, RichString.fromString("A fatal error has occured"))};
    assertEq(expected = expected, list)



@Test
def testRunWithChain02(): Unit \ Assert =
    let (_, list) = run {
        Logger.fatal("A fatal error has occured");
        Logger.info("An info line")
    } with runWithList;
    let expected = List#{(Severity.Fatal, RichString.fromString("A fatal error has occured"))};
    assertEq(expected = expected, list)