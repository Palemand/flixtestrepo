// What toX but skipping some log levels? Or is that already possible?


def handleWithSeverityFilter(filter: Set[Severity], f: a -> b \ ef): a -> b \ (ef - Logger) + Logger = 
    x -> run {
        f(x)
    } with handler Logger {
        def log(s, m, k) = {
            if (Set.exists(a -> a == s, filter)) {
                k(Logger.log(s,m))
            } else {
                k()
            }
        }
    }

def runWithSeverityFilter(filter: Set[Severity], f: Unit -> b \ ef): b \ (ef - Logger) + Logger = handleWithSeverityFilter(filter, f)()
