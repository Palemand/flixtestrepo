use Console.print
use MyPrint.myPrint
/* eff DivByZero {
    def divByZero(): Void
}

def divide(a: Int32, b: Int32): Int32 \ {DivByZero} = {
    if (b == 0) {
        DivByZero.divByZero()
    } else {
        a/b
    }
}

def main(): Unit \ {IO} =
    run { 
        let res = divide(5, 2);
        println(res)
    } with handler DivByZero {
        def divByZero(_) = {println("Div by zero err")}
    } */

eff MyPrint {
    def myPrint(str: String): Unit
}

//Making the standard handler
def myHandle(f: (a -> b \ ef)): (a -> b \ (ef - MyPrint) + IO) = 
    x -> run {
        f(x)
    } with handler MyPrint {
        def myPrint(str, k) = {println(str); k()}
    }


//"applying" the default handler
def runWithIO(f: (Unit -> a \ ef)):    a \ (ef - MyPrint) + IO = 
    myHandle(f)()



//making the reverse handler ( notice that now the function that is handled has to have ret type Unit)
def revHandle(f: (a -> Unit \ ef)): (a -> Unit \ (ef - MyPrint) + IO) = 
    x -> run {
        f(x)
    } with handler MyPrint {
        def myPrint(str, k) = {k(); println(str)}
    }

//same thing
def runWithRev(f: (Unit -> Unit \ ef)):    Unit \ (ef - MyPrint) + IO =
    revHandle(f)()



// cannot be ran with reverse handler, since the return type is not the same as println (Unit)
/* def returns(): Int32 \ IO =
    run {
        myPrint("bonk");
        0
    } with runWithRev
 */

// ------------------
def runWithCollect(f: (Unit -> a \ ef)): (a, String) \ (ef - MyPrint) =
    run {
        (f(), "")
    } with handler MyPrint {
        def myPrint(str, k) = {
            let (result, msg) = k();
            let acc = str + msg;
            (result, acc)
        }
    }


/* let collect = handler
    (* We return the value of the computation and a string. *)
    | x -> (x, "")
    | effect (Print msg) k ->
      (* First see what the rest of the computation returns and prints... *)
      let (result, msgs) = continue k () in
      (* Add the string that we want to print at the begining. *)
        (result, msg ^ msgs)
;; */

def main(): Unit \ {IO} =
    //reverse thingy
/*     run {
        myPrint("A");
        myPrint("B");
        myPrint("C");
        println("What about second hej")
    } with runWithRev */
    let (_, b) = run {
        myPrint("A");
        myPrint("B");
        myPrint("C")
    } with runWithCollect;
    println(b)
    //crazy

