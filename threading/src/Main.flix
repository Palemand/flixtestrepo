// The main entry point.
def main(): Unit \ {Chan, NonDet, IO}=
    region rc {
        run {
            let (tx, rx) = Channel.unbuffered();
            spawn runsInThread(rx) @ rc;
            Time.Sleep.sleep(Time.Duration.seconds(1));
            Channel.send(5, tx)
        } with Time.Sleep.runWithIO
    }


def runsInThread(reciever: Receiver[Int32]): Unit \ {Chan, NonDet, IO} = 
    let x = Channel.recv(reciever);
    println(x)