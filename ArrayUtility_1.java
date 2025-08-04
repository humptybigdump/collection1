package task1;

import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;

/**
 * This class provides utility for working with arrays.
 *
 * @author uezxa
 */
public class ArrayUtility {
    /**
     * Main entry point to the application. Simply copies
     * and reverses a given array.
     *
     * @param args The command line arguments (ignored)
     */
    public static void main(String[] args) {
        int[] array = {5, 4, 8, 12, 56, 0, 12, 8, 10};
        List<Integer> list = new ArrayList<>();
        int[] copy = copy(array);
        printArray(copy);

        int[] reversed = reverse(array);
        printArray(reversed);
    }

    /**
     * This method shows an example usage of the StringJoiner, that can later
     * be used in assignments. It prints out the array in a visually appealing
     * style.
     *
     * @param numbers The array that is printed
     */
    public static void printArray(int[] numbers) {
        StringJoiner stringJoiner = new StringJoiner(", ", "[", "]");
        for (int number : numbers) {
            stringJoiner.add(String.valueOf(number));
        }
        System.out.println(stringJoiner);
    }

    private static int[] copy(int[] array) {
        int[] copy = new int[array.length];
        for (int i = 0; i < array.length; i++) {
            copy[i] = array[i];
        }
        return copy;
    }

    private static int[] reverse(int[] array) {
        int[] reversed = new int[array.length];
        for (int i = 0; i < array.length; i++) {
            reversed[i] = array[array.length - 1 - i];
        }
        return reversed;
    }
}
