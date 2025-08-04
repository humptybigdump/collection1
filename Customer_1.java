package model;

/**
 * This class represents a Customer.
 * @author ugmom
 */
public class Customer {
    private String name;
    private Car rentedCar;
    private int rentalDays;

    /**
     * Constructs a customer.
     * @param name is the name of the customer
     * @param rentedCar is the rental car of the customer.
     * @param rentalDays are the rental days
     */
    public Customer(String name, Car rentedCar, int rentalDays) {
        this.name = name;
        this.rentedCar = rentedCar;
        this.rentalDays = rentalDays;
    }

    /**
     * Creates a copy of a customer.
     * @param other is the copy target.
     */
    public Customer(Customer other) {
        this.name = other.name;
        this.rentedCar = other.rentedCar;
        this.rentalDays = other.rentalDays;
    }

    /**
     * Gets the name.
     * @return the name.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name of the customer.
     * @param name is the name of the customer.
     */
    public void setName(String name) {
        if (name == null || name.isBlank()) {
            return;
        }

        this.name = name;
    }

    /**
     * Gets the rental car.
     * @return the rental car.
     */
    public Car getRentedCar() {
        return rentedCar;
    }

    /**
     * Sets the rental car.
     * @param rentedCar is the new rental car.
     */
    public void setRentedCar(Car rentedCar) {
        if (rentedCar == null) {
            return;
        }

        this.rentedCar = rentedCar;
    }

    /**
     * Gets the rental days.
     * @return the rental days.
     */
    public int getRentalDays() {
        return rentalDays;
    }

    /**
     * Sets the rental days
     * @param rentalDays is the new rental days.
     */
    public void setRentalDays(int rentalDays) {
        if (rentalDays < 0) {
            return;
        }

        this.rentalDays = rentalDays;
    }

    /**
     * Calculates the total cost of renting a car under a specific rental service.
     * @param service is the rental service.
     * @return the total cost.
     */
    public double calculateRentalCost(RentalService service) {
        return service.calculateRentalCost(rentedCar, rentalDays);
    }
}
