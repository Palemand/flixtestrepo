use IoError.IoError
import java.lang.Math
/* 
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




/* 
RetryN
RetryWithExponentialBackOff -- retrying but with increasingly longerdelay.
RetryUntil -- something about retrying until a condition is met, e.g. 5min has passed.
RecoverWith: If something fails then do something else.
 */

//retryN is done already


//retryUntil has to repeat until the boolean is set. Doesn't allow anything in the function f to change it though?
def retryUntil(negCondRef: Ref[Bool, r], f: (a -> Result[e, b] \ ef)): a -> Result[e, b] \ {r, ef, IO} = 
p -> {
    let r = f(p);
    match r {
        case Ok(x) => Ok(x)
        case Err(t) => {
            if (not Ref.get(negCondRef)) {
                retryUntil(negCondRef, f)(p)
            } else {
                Err(t)
            }
        }
    }
}

//usage
def runDnsWithResultUntil(): Unit \ {IO} =
    region rc {
        let refBool = Ref.fresh(rc, true);
        let r = run {
            let res = retryUntil(refBool, DnsWithResult.lookup)("nellemannthorsen.notdk");
            res
        } with DnsWithResult.runWithIO;
        println(r)
    }
//Usage with dns
def runDnsUntil(): Unit \ {IO} =
    region rc {
        let refBool = Ref.fresh(rc, false);
        let r = run {
            let res = Dns.lookup("nellemannthorsen.notdk");
            Ref.put(true, refBool);
            res
        } with retryUntil(refBool, Dns.runWithIO);
        println(r)
    }

// kinda useless atm

//RetryWithExponentialBackOff
def recDelay(f: Unit -> b \ ef, delay_t: Int64, now: Int64): b \ {Clock} + ef = 
    let newTime = Clock.currentTime(TimeUnit.Seconds);
    if (newTime > now + delay_t) {
        f()
    } else {
        recDelay(f, delay_t, now)
    }

def wait(t: Int32): Unit \ Clock = 
    let now = Clock.currentTime(TimeUnit.Seconds);
    let t_64 = Int32.toInt64(t);
    recDelay(() -> (), t_64, now)

def transformingDelay(t: Int32, f: a -> b \ ef): a -> b \ ef + Clock = 
    let fkt = p -> {
        wait(t); 
        f(p)
    };
    fkt

def retryWithExponentialBackOff(f: a -> Result[e, b] \ ef): a -> Result[e, b] \ ef + Clock =  retryer(0, f)
def retryer(i: Int32, f: a -> Result[e, b] \ ef): a -> Result[e, b] \ ef + Clock =
    p -> {
        let r = f(p);
        match r {
            case Ok(x) => Ok(x)
            case Err(_t) => {
                wait(i * i);
                retryer(i + 1, f)(p)
            }
        }
    }
//should just work


// RecoverWith: If something fails then do something else.
//now curried properly for partial application -- DO TO OTHERS ASWELL
def recoverWith(f: a -> Result[e, b] \ ef, g: e -> Result[x, b] \ ef2 ): a -> Result[x, b] \ ef + ef2 = 
    p -> {
        let r = f(p);
        match r {
            case Ok(x) => Ok(x)
            case Err(t) => g(t)
        }
    }

def recover(_err: IoError): Result[String, IpAddr] =
    Err("Something went massively wrong")
def runDnsRecoverWithPrint(): Unit \ IO =
    let dnsRunWithRecover = recoverWith(Dns.runWithIO); //partial
    let x = run {
        Dns.lookup("nellemannthorsen.notdk")
    } with dnsRunWithRecover(recover);
    println(x)

