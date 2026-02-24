
def main2(): Unit \ IO = 
    ???


def addWithprint(a: Int32, b: Int32): Int32 \ Console = 
    Console.println(Int32.toString(a));
    a + b

def foo(): Int32 \ IO =
    run {
        let _ = addWithprint(2, 3);
        5
    } with handler Console {
        def readln(k) = ???
        def print(s, k) = ???
        def eprint(s, k) = ???
        def println(s, k) = {
            k() + 5
        }
        def eprintln(s, k) = ???
    }