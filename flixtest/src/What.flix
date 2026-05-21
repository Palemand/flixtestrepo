use RandomBool.randomBool

eff RandomBool {
    def randomBool(): Bool
}

def program(): Unit \ IO + RandomBool =
    //let ls = randomBool() :: randomBool() :: randomBool() :: Nil;
    let ls = List.repeat(3, 0) |> List.map(_ -> randomBool());
    if (ls == List#{false, true, false}) {
        println(ls)
    } else {
        println("womp womp")
    }

def runProgramWithList(): Unit \ IO =
    let _ = run {
        program()
    } with runWithList; ()


def runWithList(f: Unit -> a \ ef): List[a] \ ef - RandomBool =
    run {
        f() :: Nil
    } with handler RandomBool {
        def randomBool(k) = k(true) ::: k(false)
    }