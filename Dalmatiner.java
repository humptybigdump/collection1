public class Dalmatiner extends Dog {
    public Dalmatiner(String name) {
        super(name);
    }

    @Override
    public void moveTo(int location) {
        super.moveTo(location);
        System.out.println("Dalmatiner moved to " + location);
    }
}
