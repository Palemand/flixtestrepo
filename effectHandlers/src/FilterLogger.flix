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



def handleWithSeverityFilter2(filterFun: Severity -> Bool \ ef1, f: a -> b \ ef2): a -> b \ (ef1 - Logger) + Logger + ef2 = 
    x -> run {
        f(x)
    } with handler Logger {
        def log(s, m, k) = {
            if (filterFun(s)) {
                k(Logger.log(s,m))
            } else {
                k()
            }
        }
    }

def runWithSeverityFilter2(filter: Severity -> Bool \ ef1, f: Unit -> b \ ef2): b \ (ef1 - Logger) + Logger + ef2 = handleWithSeverityFilter2(filter, f)()
