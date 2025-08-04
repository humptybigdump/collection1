package task2;

import task1.ArrayUtility;

/**
 * This class allows the use of the Bubble Sort algorithm on arrays.
 *
 * @author uezxa
 */
public class BubbleSort {

    /**
     * Main entry point to the application. Creates an array with
     * random values and sorts it using Bubble Sort
     *
     * @param args The command line arguments (ignored)
     */
    public static void main(String[] args) {
        int[] numbers = new int[10];

        // Fill the array with random numbers
        for (int i = 0; i < numbers.length; i++) {
            numbers[i] = (int) (Math.random() * 100);
        }
        ArrayUtility.printArray(numbers);

        // Sort the array with Bubble Sort
        int[] sorted = bubbleSort(numbers);

        // Print the sorted array
        ArrayUtility.printArray(sorted);
    }

    private static int[] bubbleSort(int[] numbers) {
        boolean swapped;
        do {
            swapped = false;
            for (int i = 0; i < numbers.length - 1; i++) {
                if (numbers[i] > numbers[i + 1]) {
                    int temp = numbers[i];
                    numbers[i] = numbers[i + 1];
                    numbers[i + 1] = temp;
                    swapped = true;
                }
            }
        } while (swapped);
        return numbers;
    }
}