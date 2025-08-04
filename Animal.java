public class Animal {
    protected String name;
    protected int location;

    public Animal(String name, int location) {
        this.name = name;
        this.location = location;
    }

    public Animal(String name) {
        this.name = name;
    }

    public void moveTo(int location) {
        System.out.println("Moving to " + location);
        this.location = location;
    }

    @Override
    public String toString() {
        return name;
    }
}
