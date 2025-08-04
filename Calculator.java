package task1;

/**
 * Provides basic functionality for calculations with integers.
 *
 * @author uezxa
 */
public class Calculator {

    /**
     * Calculates the sum of all integers from 1 to {@code n}.
     * If {@code n} is greater than 1,000,000, the method will return -1.
     *
     * @param n The upper bound of the sum (inclusive).
     * @return The sum of all integers from 1 to {@code n}, or -1 if {@code n} exceeds 1,000,000.
     */
    public int sumUntil(int n) {
        if (n > 1000000) {
            return -1;
        }

        int sum = 0;
        for (int i = 1; i <= n; i++) {
            sum += i;
        }

        return sum;
    }

    /**
     * Calculates the factorial of {@code n}.
     * If {@code n} is greater than 12, the method will return -1 due to potential overflow.
     *
     * @param n The number to calculate the factorial of.
     * @return The factorial of {@code n}, or -1 if {@code n} exceeds 12.
     */
    public int factorial(int n) {
        if (n > 12) {
            return -1;
        }

        int factorial = 1;
        for (int i = 1; i <= n; i++) {
            factorial *= i;
        }
        return factorial;
    }
}