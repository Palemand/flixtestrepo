// To List?


pub def handleWithList(f: a -> b \ ef): a -> (b, List[(Severity, RichString)]) \ (ef - Logger) =
    x -> run {
        (f(x), List.empty())
    } with handler Logger {
        def log(s, m, k) = {
            let (r, l) = k();
            (r, (s,m) :: l)
        }
    }

pub def runWithList(f: Unit -> b \ ef): (b, List[(Severity, RichString)]) \ (ef - Logger) = handleWithList(f)()