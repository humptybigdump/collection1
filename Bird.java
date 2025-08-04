package abstr;

public class Bird extends Animal {

    @Override
    public void moveTo(int loc) {
        System.out.println("Bird moving to " + loc);
    }

}
