use DnsWithResult.lookup
use DelayList.LList
use DelayList.ECons
use DelayList.ENil
use DelayList.LCons
def retryWithPol(f: a -> Result[e, b] \ ef, pol: DelayList[Int32]): a -> Result[e, b] \ ef + Clock + IO = 
    p -> {
        let r = f(p);
        match r {
            case Ok(x) => Ok(x)
            case Err(t) => {
                match pol {
                    case ENil => Err(t)
                    case LList(lst) => retryWithPol(f, force lst)(p)
                    case LCons(x, nxt) => {
                        println("Starting wait with " + Int32.toString(x)+ " seconds");
                        wait(x);
                        retryWithPol(f, force nxt)(p)
                    }
                    case ECons(x, nxt) => {
                        println("Starting wait with " + Int32.toString(x)+ " seconds");
                        wait(x);
                        retryWithPol(f, nxt)(p)
                    }
                }   
            }
        }
    }

//hmmm
def runDnsWithRetryNPol(): Unit \ IO + Clock =
    let nzeros = DelayList.repeat(1) |> DelayList.take(10);
    let x = run {
        retryWithPol(DnsWithResult.lookup, nzeros)("nellemannthorsen.notdk")
    } with DnsWithResult.runWithIO;
    println(x)

def runDnsWithExpPol(): Unit \ IO + Clock =
    let pol = DelayList.startFrom(1) |> DelayList.map(p -> p*p) |> DelayList.take(10);
    let x = run {
        retryWithPol(lookup, pol)("nellemannthorsen.notdk")
    } with DnsWithResult.runWithIO;
    println(x)

def runDnsUntillSomethingPol(): Unit \ IO + Clock = 
    let pol = DelayList.repeat(1);
