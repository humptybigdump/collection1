package edu.kit.kastel;

/**
 * Abstract class representing a type of candy. Might be a singular piece of candy or multiple ones.
 * @author Programmieren-Team
 */
public abstract class Candy {

    protected int quantity;
    private final String name;
    private final int price;

    /**
     * Constructs a new Candy with the given name, quantity, and price.
     * @param name is the name of the candy.
     * @param quantity is the quantity of the candy.
     * @param price is the price of the candy in cents.
     */
    public Candy(String name, int quantity, int price) {
        this.name = name;
        this.quantity = quantity;
        this.price = price;
    }

    /**
     * Gets the name of the candy.
     * @return The name of the candy.
     */
    public String getName() {
        return name;
    }

    /**
     * Gets the quantity of the candy.
     * @return The quantity of the candy.
     */
    public int getQuantity() {
        return quantity;
    }

    /**
     * Copies the current state of the candy into a new instance.
     * @return A copy of the candy.
     */
    public abstract Candy copy();

    /**
     * Abstract method representing the action of eating the candy. Subclasses should provide their specific implementation.
     */
    public abstract void eat();

    /**
     * Returns a string representation of the candy.
     * @return A string representation of the candy.
     */
    @Override
    public String toString() {
        return "Candy{" + "name='" + name + '\'' + ", quantity=" + quantity + ", price=" + price + '}';
    }
}
