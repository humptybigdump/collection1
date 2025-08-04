/**
 * This class represents a Car object.
 * @author ugmom
 */
public class Car {
    private int seats;
    private String color;

    /**
     * This constructs a Car.
     * @param seats is the number of seats
     * @param color is the colour of the car
     */
    public Car(int seats, String color) {
        this.seats = seats;
        this.color = color;
    }

    /**
     * Copies a Car object.
     * @param original is the clone target
     */
    public Car(Car original) {
        this.seats = original.seats;
        this.color = original.color;
    }

    /**
     * Gets the seat count
     * @return the seat count
     */
    public int getSeats() {
        return seats;
    }

    /**
     * Gets the colour.
     * @return the colour
     */
    public String getColor() {
        return color;
    }

    /**
     * Sets the seat count
     * @param seats the new seat count
     */
    public void setSeats(int seats) {
        this.seats = seats;
    }

    /**
     * Sets the colour.
     * @param color is the new colour
     */
    public void setColor(String color) {
        this.color = color;
    }
}
