package model;

/**
 * This class represents a rentable car.
 * @author ugmom
 */
public class Car {
    private String model;
    private int year;
    private double pricePerDay;

    /**
     * Constructs a car.
     * @param model is the name of the model
     * @param year is the year
     * @param pricePerDay is the price per day
     */
    public Car(String model, int year, double pricePerDay) {
        this.model = model;
        this.year = year;
        this.pricePerDay = pricePerDay;
    }

    /**
     * Gets the model.
     * @return the model.
     */
    public String getModel() {
        return model;
    }

    /**
     * Sets the model.
     * @param model is the new model.
     */
    public void setModel(String model) {
        if (model == null || model.isBlank()) {
            return;
        }
        this.model = model;
    }

    /**
     * Gets the year.
     * @return the year.
     */
    public int getYear() {
        return year;
    }

    /**
     * Sets the year.
     * @param year is the new year.
     */
    public void setYear(int year) {
        if (year < 0) {
            return;
        }
        this.year = year;
    }

    /**
     * Gets the price per day.
     * @return the price per day.
     */
    public double getPricePerDay() {
        return pricePerDay;
    }

    /**
     * Sets the price.
     * @param pricePerDay is the new price.
     */
    public void setPricePerDay(double pricePerDay) {
        if (pricePerDay < 0) {
            return;
        }
        this.pricePerDay = pricePerDay;
    }
}
