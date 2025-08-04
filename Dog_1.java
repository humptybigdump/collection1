public class Dog extends Animal {

    public Dog(String name) {
        super(name, 0);
        System.out.println("Dog created");

        String s = "";
        String out = s.replace('a', ' ');

        String.format("%d %d", 1, 3);
    }

    @Override
    public void moveTo(int location) {
        super.moveTo(location);
        System.out.println(name + " moved to " + location);
    }

    public static void main(String[] args) {
        Dog animal = new Dalmatiner("Bruno");
        animal.moveTo(5);

        animal = null;

        animal.moveTo(0);
    }
}
