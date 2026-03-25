import java.io.Console
def main(): Unit \ IO =
    run {
        readIn()
    } with Sys.Console.runWithIO

@Tailrec
def readIn(): Unit \ Sys.Console =
    let stdIn = Sys.StdIn.StdIn;
    let x = std.read();
    Sys.Console.println("s");
    readIn()