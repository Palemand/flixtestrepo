//Arraylist[Cat] forholdes på hvilken måde med List[Animal]?
import java.util.*;

public class Main {
    public static void main(String[] args) {
        List<Animal> animals = new ArrayList<>();
        animals.add(new Cat());
        processAnimals(animals);

        ArrayList<Cat> cats = new ArrayList<>();
        cats.add(new Cat());
        processCats(cats); // works
        //processCats(cats); // this wont

    }
    
    public static void processAnimals(List<Animal> animals) {
        for (Animal animal : animals) {
            animal.doNothing();
        }
    }

    public static void processCats(ArrayList<Cat> cats) {
        for (Cat cat : cats) {
            cat.meow();
        }
    }
}
