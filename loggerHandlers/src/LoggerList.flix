/* // To List?


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




 */

    ///
    /// Handles the `Logger` effect of the given function `f`.
    ///
    /// In other words, returns a list of `(Severity, RichString)` that represents and is ordered by the calls to log.
    ///
    pub def handleWithList(f: a -> b \ ef): a -> (b, List[(Severity, RichString)]) \ (ef - Logger) =
        x -> run {
            (f(x), List.empty())
        } with handler Logger {
            def log(s, m, k) = {
                let (r, l) = k();
                (r, (s, m) :: l)
            }
        }

    ///
    /// Runs the `Logger` effect of the given function `f`.
    ///
    /// In other words, returns a list of `(Severity, RichString)` that represents and is ordered by the calls to log.
    ///
    pub def runWithList(f: Unit -> b \ ef): (b, List[(Severity, RichString)]) \ (ef - Logger) = handleWithList(f)()