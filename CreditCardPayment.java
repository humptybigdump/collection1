package PaymentTypes;

public class CreditCardPayment implements Payment {
    public static final int MAX_LIMIT = 10000;
    public static final String ERROR_MESSAGE = "The amount is over 10000.";

    @Override
    public void processPayment(double payment) throws IllegalArgumentException {
        if (payment > MAX_LIMIT) {
            throw new IllegalArgumentException(ERROR_MESSAGE);
        }
    }
}
