package hashes;

public class BrokenDog {
    public String name;
    public int age;

    public BrokenDog(String name, int age) {
        this.name = name;
        this.age = age;
    }

    @Override
    public int hashCode() {
        return 0;
    }

    @Override
    public boolean equals(Object obj) {
        return true;
    }
}
