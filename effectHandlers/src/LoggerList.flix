// To List?


def handleWithList(f: a -> b \ ef): a -> (b, List[(Severity, RichString)]) \ (ef - Logger) =
    x -> run {
        (f(x), List.empty())
    } with handler Logger {
        def log(s, m, k) = {
            let (res, lst) = k();
            (res, List.append(lst, List#{(s,m)}))
        }
    }

def runWithList(f: Unit -> b \ ef): (b, List[(Severity, RichString)]) \ (ef - Logger) = handleWithList(f)()