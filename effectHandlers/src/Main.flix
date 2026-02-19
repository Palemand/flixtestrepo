
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

// fjern alle `RichString.`
pub def checkEqual(rs1: RichString, rs2: RichString): Bool = 
    let (RichString.RichString(rs1Chain), RichString.RichString(rs2Chain)) = (rs1, rs2);
    Chain.forAll((spans -> {
        let (RichString.Span.Span(rs1Span), RichString.Span.Span(rs2Span)) = spans;
        let {text = rs1text, fgColor = rs1fg, bgColor = rs1bg, styles = rs1Styles} = rs1Span;
        let {text = rs2text, fgColor = rs2fg, bgColor = rs2bg, styles = rs2Styles} = rs2Span;
        rs1text == rs2text and rs1fg == rs2fg and rs1bg == rs2bg and rs1Styles == rs2Styles
    }), Chain.zip(rs1Chain, rs2Chain))