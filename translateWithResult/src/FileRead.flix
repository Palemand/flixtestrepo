
// This part shoul be in FileRead effect file
def handleWithFileReadWithResult(func: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - FileRead) + FileReadWithResult =
    y -> run {
        Ok(func(y))
    } with handler FileRead {
        def exists(f, k) = {
            match FileReadWithResult.exists(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isDirectory(f, k) = {
            match FileReadWithResult.isDirectory(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isRegularFile(f, k) = {
            match FileReadWithResult.isRegularFile(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isReadable(f, k) = {
            match FileReadWithResult.isReadable(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isSymbolicLink(f, k) = {
            match FileReadWithResult.isSymbolicLink(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isWritable(f, k) = {
            match FileReadWithResult.isWritable(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def isExecutable(f, k) = {
            match FileReadWithResult.isExecutable(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def accessTime(f, k) = {
            match FileReadWithResult.accessTime(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def creationTime(f, k) = {
            match FileReadWithResult.creationTime(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def modificationTime(f, k) = {
            match FileReadWithResult.modificationTime(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def size(f, k) = {
            match FileReadWithResult.size(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def read(f, k) = {
            match FileReadWithResult.read(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def readLines(f, k) = {
            match FileReadWithResult.readLines(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def readBytes(f, k) = {
            match FileReadWithResult.readBytes(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
        def list(f, k) = {
            match FileReadWithResult.list(f) {
                case Ok(ok) => k(ok)
                case Err(t) => Err(t)
            }
        }
    }

def runWithFileReadWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - FileRead) + FileReadWithResult = handleWithFileReadWithResult(f)()





//This part should be in W effect file
def handleWithFileRead(func: (a -> Result[e, b] \ ef) ): (a -> b \ (ef - FileReadWithResult) + FileRead) =
    y -> let x = run {
        func(y)
    } with handler FileReadWithResult {
        def exists(f, k) = k(Ok(FileRead.exists(f)))
        def isDirectory(f, k) = k(Ok(FileRead.isDirectory(f)))
        def isRegularFile(f, k) = k(Ok(FileRead.isRegularFile(f)))
        def isReadable(f, k) = k(Ok(FileRead.isReadable(f)))
        def isSymbolicLink(f, k) = k(Ok(FileRead.isSymbolicLink(f)))
        def isWritable(f, k) = k(Ok(FileRead.isWritable(f)))
        def isExecutable(f, k) = k(Ok(FileRead.isExecutable(f)))
        def accessTime(f, k) = k(Ok(FileRead.accessTime(f)))
        def creationTime(f, k) = k(Ok(FileRead.creationTime(f)))
        def modificationTime(f, k) = k(Ok(FileRead.modificationTime(f)))
        def size(f, k) = k(Ok(FileRead.size(f)))
        def read(f, k) = k(Ok(FileRead.read(f)))
        def readLines(f, k) = k(Ok(FileRead.readLines(f)))
        def readBytes(f, k) = k(Ok(FileRead.readBytes(f)))
        def list(f, k) = k(Ok(FileRead.list(f)))
    };
    match x {
        case Ok(k) => k
        case Err(_t) => unreachable!() //allegedly
    }

def runWithDnsFileRead(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - FileReadWithResult) + FileRead = handleWithFileRead(f)()
