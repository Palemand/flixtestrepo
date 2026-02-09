trait MyFoldable[t: Type] {
    type Aef : Eff
    type Elm : Type

    pub def fold(f: ((acc, MyFoldable.Elm[t]) -> acc \ ef), init: acc, lst: t): acc \ MyFoldable.Aef[t] + ef
}

instance MyFoldable[List[k]] {
    type Aef = {}
    type Elm = k

    pub def fold(f: ((acc, k) -> acc \ ef), init: acc, lst: List[k]): acc \ ef = {
        ???
    }
}

instance MyFoldable[MutList[k, rc]] {
    type Aef = rc
    type Elm = k

    pub def fold(f: acc -> (k -> acc \ ef), init: acc, lst: MutList[k, rc]): acc \  rc + ef = ???
}

//crazy
// The main entry point.
def main(): Unit \ IO =
    println("Hello World!")



trait MyForeachable[t: Type]{
    type Aef : Eff
    type Elm : Type

    pub def myForeach(f: (MyForeachable.Elm[t] -> Unit \ ef), lst: t): Unit \ MyForeachable.Aef[t] + ef
}

instance MyForeachable[List[t]] {
    type Aef = {}
    type Elm = t

    pub def myForeach(f: t -> Unit \ ef, lst: List[t]): Unit \  ef = {
        ???
    }

}
