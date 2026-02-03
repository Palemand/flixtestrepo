public class MyOtherException<T> extends Exception {
    private T someType;

    public MyOtherException(String message) {
        super(message);
    }

    public T getType() {
        return someType;
    }
    
}
