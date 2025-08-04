/**
 * Simulates a drink in the vending machine.
 *
 * @author uhnru
 */
public class Drink {
    private String name;
    private double price;
    private int quantity;
    private static final String OUTPUT_FORMAT = "Name: %s, Price: %.2f, Quantity: %d";

    /**
     * Gets the quantity of the drink.
     *
     * @return the quantity of the drink.
     */
    public int getQuantity() {
        return quantity;
    }

    /**
     * Sets the quantity of the drink.
     *
     * @param quantity the new quantity of the drink;
     */
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    @Override
    public String toString() {
        return String.format(OUTPUT_FORMAT, name, price, quantity);
    }
}
