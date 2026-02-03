use FileWriteWithResult.runWithIO
// The main entry point.

// Handlers kan bruges til at være "adapter" mellem effekter. Eg. handle console ved at logge til en fil.

def main(): Unit \ IO =
    run {
        usesConsole()
    } with handler Console {
        def readln(k) = k("s")
        def print(_s, k) = k()
        def eprint(_s, k) = k()
        def println(s, k) = {
            Logger.info(s);
            k()
        }
        def eprintln(_, k) = k()
    } with handler Logger {
        def log(_, m, k) = {
            let _ = FileWriteWithResult.write({str = RichString.toString(m)}, "test.txt");
            k()
        }
    } with FileWriteWithResult.runWithIO

def usesConsole(): Unit \ Console =
    Console.println("Flix er nice")
