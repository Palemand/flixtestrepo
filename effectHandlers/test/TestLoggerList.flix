use Assert.{assertEq}

@Test
def testRunWithList01(): Unit \ Assert =
    let (_, list) = run {
        Logger.fatal("A fatal error has occured")
    } with runWithList;
    let expected = List#{(Severity.Fatal, RichString.fromString("A fatal error has occured"))};
    assertEq(expected = expected, list)



@Test
def testRunWithList02(): Unit \ Assert =
    let (stdRes, list) = run {
        Logger.fatal("A fatal error has occured");
        Logger.info("An info line");
        5 // to show that we have more code executing "normally"
    } with runWithList;
    let expected = List#{
        (Severity.Fatal, RichString.fromString("A fatal error has occured")),
        (Severity.Info, RichString.fromString("An info line"))
    };
    assertEq(expected = expected, list);
    assertEq(expected = 5, stdRes)