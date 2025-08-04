public class Barn implements StorageField {
    private final int id;
    private final int capacity;
    private int amount;

    public Barn(int id, int capacity) {
        this.id = id;
        this.capacity = capacity;
    }

    public int getId() {
        return id;
    }

    public int getCapacity() {
        return capacity;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    @Override
    public StorageField asStorageField() {
        return this;
    }

    @Override
    public boolean canStore(String plant) {
        return !plant.equals("wheat");
    }

    @Override
    public String getSymbol() {
        return "B";
    }
}
