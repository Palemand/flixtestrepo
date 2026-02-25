import java.time.Duration
// The main entry point.
def main(): Unit \ IO + Env =
    let args = Env.getArgs();
    println("Arguments: ${args}");
    let amount = match List.head(args) {case Some(x) => x case None => "0"} |> {a -> match Int64.fromString(a) {case Some(x) => x case None => 0i64}};
    println("Amount chosen: " + ToString.toString(amount));
    let rc1 = makeNSpanRichString(amount);
    let rc2 = makeNSpanRichString(amount);
    println(ToString.toString(rc1));
    //println(ToString.toString(rc2));
    println(ToString.toString(rc1 == rc2))


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


def makeNSpanRichString(n: Int64): RichString = 
    def help(i: Int64, acc: RichString): RichString =
        if (i == 0i64) {
            acc
        } else {
            help(i - 1i64, RichString.combine(RichString.fromString(Int64.toString(i) + " "), acc))
        };
    help(n, RichString.fromString(""))

def timeEqualsOfNSpanRC(n: Int64): (Int64, Bool) =
    let _rc = makeNSpanRichString(n);
    let _rc2 = makeNSpanRichString(n);
    //let startTime = Clock.currentTime(TimeUnit.Nanoseconds);
    //let equality = equals(rc, rc2);
    //let endTime = Clock.currentTime(TimeUnit.Nanoseconds);
    (0i64, true)


def testTime(): Unit \ IO =
    let rc = makeNSpanRichString(1000i64);
    println(RichString.toString(rc));
    println(equals(rc, rc))