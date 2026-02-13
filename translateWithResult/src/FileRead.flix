// This part shoul be in FileRead effect file
def handleWithFileReadWithResult(func: (a -> b \ ef)): a -> Result[IoError, b] \ (ef - FileRead) + FileReadWithResult =
    y -> run {
        Ok(func(y))
    } with handler FileRead {
        def exists(f, k) = helper(FileReadWithResult.exists, k)(f)
        def isDirectory(f, k) = helper(FileReadWithResult.isDirectory, k)(f)
        def isRegularFile(f, k) = helper(FileReadWithResult.isReadable, k)(f)
        def isReadable(f, k) = helper(FileReadWithResult.isReadable, k)(f)
        def isSymbolicLink(f, k) = helper(FileReadWithResult.isSymbolicLink, k)(f)
        def isWritable(f, k) = helper(FileReadWithResult.isWritable, k)(f)
        def isExecutable(f, k) = helper(FileReadWithResult.isExecutable, k)(f)
        def accessTime(f, k) = helper(FileReadWithResult.accessTime, k)(f)
        def creationTime(f, k) = helper(FileReadWithResult.creationTime, k)(f)
        def modificationTime(f, k) = helper(FileReadWithResult.modificationTime, k)(f)
        def size(f, k) = helper(FileReadWithResult.size, k)(f)
        def read(f, k) = helper(FileReadWithResult.read, k)(f)
        def readLines(f, k) = helper(FileReadWithResult.readLines, k)(f)
        def readBytes(f, k) = helper(FileReadWithResult.readBytes, k)(f)
        def list(f, k) = helper(FileReadWithResult.list, k)(f)
    }

def runWithFileReadWithResult(f: (Unit -> b \ ef)): Result[IoError, b] \ (ef - FileRead) + FileReadWithResult = handleWithFileReadWithResult(f)()


def helper(f: a -> Result[IoError, b] \ ef, k: (b -> Result[IoError, c] \ ef2)): a -> Result[IoError, c] \ ef + ef2 =
    x -> match f(x) {
        case Ok(ok) => k(ok)
        case Err(t) => Err(t)
    }




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
        case Err(_t) => unreachable!()
    }

def runWithDnsFileRead(f: (Unit -> Result[e, b] \ ef) ): b \ (ef - FileReadWithResult) + FileRead = handleWithFileRead(f)()
