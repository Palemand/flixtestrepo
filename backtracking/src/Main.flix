use RoundResult.Win
use List.range
use Range.Range
use RoundResult.Loss
use RoundResult.Draw

import java.lang.Math



def backtrack(): Unit \ {Console, Abort, IO} =
    let res: List[(Bool, List[Int32])] = run {
        List#{(playGame(), List.empty())}
    } with handler Console {
        def readln(k) = {
            let x: List[(Bool, List[Int32])] = 
            //doesnt work
            List.flatMap((
                    y -> (
                        let result = k(Int32.toString(y));
                        List.map((tuple -> (fst(tuple), snd(tuple) ::: List#{y})), result)
                    )
                ), range(0, 11));
            x
        }
        def print(_, k) = k()
        def eprint(_, k) = k()
        def println(_, k) = k()
        def eprintln(_, k) = k()
    };
    res |> List.filter(a -> fst(a)) |> List.forEach(t -> ({println(snd(t)); println(fst(t))}));
    ()


def main(): Unit \ {Console, Abort} = 
    let resultOfGame = playGame();
    if (resultOfGame) {
        Console.println("You win the game!")
    } else {
        Console.println("L bozo")
    }

/*
Game where you need to guess a number close to a pre chosen number between "0 and 10"
Opponent sequence is deterministic, and the random numbers don't change
After 3 rounds you have to have more wins than opponent
*/
enum RoundResult {
    case Win,
    case Loss,
    case Draw
}


//just indexing
def getEnemyChoice(roundNr: Int32): Int32 =
    Vector.get(roundNr, Vector#{8,3,6})

//dunno how to write a global variable
def getValue(roundRr: Int32): Int32 =
    let vec = Vector#{5,3,10};
    Vector.get(roundRr, vec)

def getInput(): Int32 \ {Console, Abort} = 
    Console.println("Please pick a number in [0, 10]");
    let userinput = Console.readln();
    let intinput = Int32.fromString(userinput);
    let x = match intinput {
        case None => Abort.abort(RichString.fromString("Must be number"))
        case Some(x) => x
    };
    x


def playRound(roundNr: Int32): RoundResult \ {Console, Abort} = 
    let input = getInput();
    let enemyChoice = getEnemyChoice(roundNr);
    let userDist = Math.abs(input - getValue(roundNr));
    let enemyDist = Math.abs(enemyChoice - getValue(roundNr));
    //Console.println("User input: "+ Int32.toString(input));
    //Console.println("Enemy input: "+ Int32.toString(enemyChoice));
    if (userDist < enemyDist) {
        //Console.println("You won!");
        RoundResult.Win
    } else if (userDist == enemyDist){
        //Console.println("That was a draw!");
        RoundResult.Draw
    } else {
        //Console.println("You loose");
        RoundResult.Loss
    }

def playGame(): Bool \ {Console, Abort} =
    let results = List.map((x -> playRound(x)), range(0,3));
    let f = (
        acc -> (x -> match x {
            case RoundResult.Win => (fst(acc)+1, snd(acc)) 
            case RoundResult.Draw => acc
            case RoundResult.Loss => (fst(acc), snd(acc) +1) 
        })
    );

    let (pWins, eWins) = List.foldLeft(f, (0,0), results);
    (pWins >= eWins)