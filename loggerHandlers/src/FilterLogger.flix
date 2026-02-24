// What toX but skipping some log levels? Or is that already possible?


/* 
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

 */

def handleWithFilter(filter: (Severity, RichString) -> Bool \ ef1, f: a -> b \ ef2): a -> b \ (ef2 - Logger) + Logger + ef1 = 
    x -> run {
        f(x)
    } with handler Logger {
        def log(s, m, k) = {
            if (filter(s, m)) {
                k(Logger.log(s,m))
            } else {
                k()
            }
        }
    }

def runWithFilter(filter: (Severity, RichString) -> Bool \ ef1, f: Unit -> b \ ef2): b \ (ef2 - Logger) + Logger + ef1 = handleWithFilter(filter, f)()

def onlyLevels(set: Set[Severity]): (Severity, RichString) -> Bool = 
    (sev, _) -> Set.exists(a -> a == sev, set)