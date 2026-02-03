def main(): Unit \ {IO} =
    let str = readFileToString("stuff/filetoberead.txt");
    let str2 = readFileWithResultToString("stuff/filetoberead.txt");
    println(str);
    println(str2)
    

//hvorfor fuck skal det være sådan her?
def readFileToString(path: String): String \ IO =
    let balls = run {
        let s = FileRead.read(path);
        s
    } with FileRead.runWithIO;

    match balls {
        case Ok(str) => str
        case Err(_) => "sut min dut"
    }

def readFileWithResultToString(path: String): String \ IO =
    run {
        let result = FileReadWithResult.read(path);
        match result {
            case Ok(str) => str
            case Err(_) => "sut min dut"
        }
    } with FileReadWithResult.runWithIO




// so what if the FileRead, gets handled further out?
// ahhh thats why this exists
def readFileToString2(path: String): String \ FileRead =
    let s = FileRead.read(path);
    s

def main2(): String \ IO =
    let _ = run {
        let str = readFileToString2("stuff/filetoberead.txt");
        println(str);
        str
    } with FileRead.runWithIO;
    "tis"
