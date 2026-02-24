use Assert.{assertTrue, assertEq}

@Test
def testRunWithList01(): Unit \ Assert =
    let (_, list) = run {
        Logger.fatal("A fatal error has occured")
    } with runWithList;
    let expected = List#{(Severity.Fatal, RichString.fromString("A fatal error has occured"))};
    assertTrue(richStringSevListEqual(expected, list))

@Test
def testRunWithList02(): Unit \ Assert =
    let (_, list) = run {
        Logger.fatal("A fatal error has occured");
        Logger.info("An info line")
    } with runWithList;
    let expected = List#{
        (Severity.Fatal, RichString.fromString("A fatal error has occured")),
        (Severity.Info, RichString.fromString("An info line"))
    };
    assertTrue(richStringSevListEqual(expected, list))

@Test
def testRunWithList03(): Unit \ Assert =
    let (stdRes, _list) = run {
        Logger.fatal("A fatal error has occured");
        5
    } with runWithList;
    assertEq(expected = 5, stdRes)

def richStringCheckEqual(rs1: RichString, rs2: RichString): Bool = 
    let (RichString.RichString(rs1Chain), RichString.RichString(rs2Chain)) = (rs1, rs2);
    Chain.forAll((spans -> {
        let (RichString.Span.Span(rs1Span), RichString.Span.Span(rs2Span)) = spans;
        let {text = rs1text, fgColor = rs1fg, bgColor = rs1bg, styles = rs1Styles} = rs1Span;
        let {text = rs2text, fgColor = rs2fg, bgColor = rs2bg, styles = rs2Styles} = rs2Span;
        rs1text == rs2text and rs1fg == rs2fg and rs1bg == rs2bg and rs1Styles == rs2Styles
    }), Chain.zip(rs1Chain, rs2Chain))

def richStringSevListEqual(l1: List[(Severity, RichString)], l2: List[(Severity, RichString)]): Bool =
    List.forAll(pair -> {
        let ((sev1, rs1), (sev2, rs2)) = pair;
        sev1 == sev2 and richStringCheckEqual(rs1, rs2)
    }, List.zip(l1, l2))