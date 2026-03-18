use DelayList.LList
use DelayList.ECons
use DelayList.ENil
use DelayList.LCons

def retryWithPol(f: a -> Result[e, b] \ ef, stopCheck: Unit -> Bool \ ef2, pol: DelayList[Int32]): a -> Result[e, b] \ ef + ef2 + Clock + IO = 
    p -> {
        let r = f(p);
        match r {
            case Ok(x) => Ok(x)
            case Err(t) => {
                if (stopCheck()) {
                    Err(t)
                } else {
                    match pol {
                        case ENil => Err(t)
                        case LList(lst) => retryWithPol(f, stopCheck, force lst)(p)
                        case LCons(x, nxt) => {
                            println("Starting wait with " + Int32.toString(x)+ " seconds");
                            wait(x);
                            retryWithPol(f, stopCheck, force nxt)(p)
                        }
                        case ECons(x, nxt) => {
                            println("Starting wait with " + Int32.toString(x)+ " seconds");
                            wait(x);
                            retryWithPol(f, stopCheck, nxt)(p)
                        }
                    }
                }
            }
        }
    }


//hmmm
def neverStop(): Bool = false

def runDnsWithRetryNPol(): Unit \ IO + Clock =
    let nzeros = DelayList.repeat(1) |> DelayList.take(10);
    let x = run {
        retryWithPol(DnsWithResult.lookup, neverStop, nzeros)("nellemannthorsen.notdk")
    } with DnsWithResult.runWithIO;
    println(x)

def runDnsWithExpPol(): Unit \ IO + Clock =
    let pol = DelayList.startFrom(1) |> DelayList.map(p -> p*p) |> DelayList.take(3);
    let x = run {
        retryWithPol(DnsWithResult.lookup, () -> false, pol)("nellemannthorsen.notdk")
    } with DnsWithResult.runWithIO;
    println(x)

def runDnsUntilPol(): Unit \ IO + Clock = 
    region rc {
        let check = Ref.fresh(rc, true);
        let pol = DelayList.repeat(1) |> DelayList.take(100);
        let x = run {
            retryWithPol(DnsWithResult.lookup, () -> Ref.get(check), pol)("awdawda.dasd")
        } with DnsWithResult.runWithIO;
        println(x)
    }


