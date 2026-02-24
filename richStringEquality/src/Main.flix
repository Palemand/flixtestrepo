// The main entry point.
def main(): Unit \ IO =
    println("Hello World!")

instance Eq[RichString] {
    pub def eq(x: RichString, y: RichString): Bool = equals(x,y)
}

def spanEquals(s1: RichString.Span, s2: RichString.Span): Bool =
    let RichString.Span.Span({text = t1, fgColor = fg1, bgColor = bg1, styles = style1}) = s1;
    let RichString.Span.Span({text = t2, fgColor = fg2, bgColor = bg2, styles = style2}) = s2;
    t1 == t2 and fg1 == fg2 and bg1 == bg2 and style1 == style2


def equals(rs1: RichString, rs2: RichString): Bool = 
    let (RichString.RichString(chain1), RichString.RichString(chain2)) = (rs1, rs2);
    let splitSpans = (span -> {
        let RichString.Span.Span({text = t, fgColor = fg, bgColor = bg, styles}) = span;
        String.toList(t) |> List.toChain |> Chain.map(c -> (RichString.Span.Span({text = Char.toString(c), fgColor = fg, bgColor = bg, styles = styles})))
    });
    let l1 = Chain.flatMap(splitSpans, chain1);
    let l2 = Chain.flatMap(splitSpans, chain2);
    Chain.zip(l1, l2) |> Chain.forAll((pair -> {let (e1, e2) = pair; spanEquals(e1, e2)}))