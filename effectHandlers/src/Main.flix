
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



instance Eq[RichString] { //Everything has to be equal for this equality not just text
    pub def eq(x: RichString, y: RichString): Bool = checkEqual(x, y)
}

pub def checkEqual(x: RichString, y: RichString): Bool = 
    let (RichString.RichString(xChain), RichString.RichString(yChain)) = (x,y);
    let xyChain = Chain.zip(xChain, yChain);
    Chain.forAll((spans -> {
        let (RichString.Span.Span(xSpan), RichString.Span.Span(ySpan)) = spans;
        let {text = xs, fgColor = xfg, bgColor = xbg, styles = xset} = xSpan;
        let {text = ys, fgColor = yfg, bgColor = ybg, styles = yset} = ySpan;
        xs == ys and xfg == yfg and xbg == ybg and xset == yset
    }), xyChain)