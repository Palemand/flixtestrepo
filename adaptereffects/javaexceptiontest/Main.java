import java.io.File;
import java.util.List;
import java.util.function.Predicate;
import java.util.function.Consumer;


public class Main {
    public final static int two = 2;
    public static List<String> list;
    
    public static void main(String[] args) throws MyException{
        try {
            // something();
            catchesAndThrows();
        } catch (Exception t) {
            System.out.println("Catched something at main");
            System.out.println(t.getMessage());
        }
    }
    
    public static void throwException() throws MyException {
        throw new MyException("Exception from throwException method.");
    }

    public static void catchesAndThrows() throws MyException {
        try {
            throwException();
        } catch (MyException e) {
            throw e;
        } finally {
            System.out.println("Finally statement print");
        }
        System.out.println("Bliver ikke printet");
    }




    // lambda stuff
    //baeldung er smarte i think
    static <T, E extends Exception> Consumer<T> handlingConsumerWrapper(
    ThrowingConsumer<T, E> throwingConsumer, Class<E> exceptionClass) {
    
        return i -> {
            try {
                throwingConsumer.accept(i);
            } catch (Exception ex) {
                try {
                    E exCast = exceptionClass.cast(ex);
                    System.err.println(
                    "Exception occured : " + exCast.getMessage());
                } catch (ClassCastException ccEx) {
                    throw new RuntimeException(ex);
                } finally {
                    System.out.println("Done handling");
                }
            }
        };
    }
    
    public static void something() throws Exception {
        Consumer<Integer> consume = handlingConsumerWrapper(i -> {throwException();}, MyException.class); //wrapped
        consume.accept(Integer.valueOf(2));
        
    }
}
