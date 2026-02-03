/* 
Kan withResult oversættes til uden?

Kan man skrive en handler til den ene effekt, der i stedet bruger den anden effekt?
Handlers kan bruges til at være "adapter" mellem effekter. Eg. handle console ved at logge til en fil.

Kan man opgradere ingen, begge eller kun den ene til at prøve igen.

Kan man skrive en højereordensfunktion der tager en int og en funktion, der retryer en funktion x gange hvis den fejler. (og for hvilke af de to)
*/

// The main entry point.
def main(): Unit =
    ()

// ------ with result
def runDnsWithRes(): Unit \ {IO} =
    let x = run {
        retry(10, DnsWithResult.lookup)("nellemannthorsen.notdk")
    } with DnsWithResult.runWithIO;
    println(x)

def retry(i: Int32, f: a -> Result[e, b] \ ef): a -> Result[e, b] \ ef + IO = 
p -> {
    let r = f(p);
    match r {
        case Ok(x) => Ok(x)
        case Err(t) => {
            if (i > 0) {
                println("We retry at: " + Int32.toString(i-1));
                retry(i-1, f)(p)
            } else {
                Err(t)
            }
        }
    }
}

// ------- Without result

/* def normalDns(): Unit \ IO = 
    run {
        Dns.lookup("adjklawdklawdl.daldk")
    } with Dns.runWithIO */
def runDns(): Unit \ IO =
    let x = run {
        Dns.lookup("nellemannthorsen.notdk")
    } with retry(1000,Dns.runWithIO);
    println(x)


def retry2(i: Int32, f: a -> Result[e, b] \ ef): a -> Result[e, b] \ ef + IO = 
p -> {
    let r = f(p);
    match r {
        case Ok(x) => Ok(x)
        case Err(t) => {
            if (i > 0) {
                println("We retry at: " + Int32.toString(i-1));
                retry2(i-1, f)(p)
            } else {
                Err(t)
            }
        }
    }
}