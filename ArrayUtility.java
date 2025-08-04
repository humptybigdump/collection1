/**
 * This class provides utilities for arrays.
 * @author ugmom
 */
public final class ArrayUtility {

    /**
     * Adds all integers in the given array.
     *
     * @param array is the provided array
     * @return the sum of all integers in the array
     */
    public static int arraySum(int[] array) {
        int sum = 0;
        //We need to declare what is in the array, as a loop variable
        for (int num : array) {
            sum += num;
        }
        return sum;
    }

    /**
     * Calculates the average value of the array.
     * @param array is the provided array
     * @return the average value of the array
     */
    public static double average(int[] array) {
        //We can use other methods in this class too!
        return (double) arraySum(array) / array.length;
    }

    /**
     * Adds to vectors.
     * @param vectorA is the first vector
     * @param vectorB is the second vector
     * @return the sum of both vectors, null if vectors are not of the same size
     */
    public static double[] sum(double[] vectorA, double[] vectorB) {
        //Remember to check for invalid inputs!
        if (vectorA.length != vectorB.length) {
            return null;
        }

        double[] sum = new double[vectorA.length];
        for (int i = 0; i < vectorA.length; i++) {
            sum[i] = vectorA[i] + vectorB[i];
        }
        return sum;
    }

    /**
     * Multiplies a vector by a scalar.
     * @param vector is the provided vector
     * @param scalar is the provided scalar
     * @return the scaled vector
     */
    public static double[] scalarMul(double[] vector, double scalar) {
        double[] result = new double[vector.length];

        //A normal for-loop is preferable since we want to loop over the indexes of the new array
        for (int i = 0; i < vector.length; i++) {
            result[i] = vector[i] * scalar;
        }
        return result;
    }

    /**
     * Adds two matrices together
     * @param matrixA is the first matrix
     * @param matrixB is the second matrix
     * @return the sum of both matrices
     */
    public static double[][] sum(double[][] matrixA, double[][] matrixB) {
        if (matrixA.length != matrixB.length) {
            return null;
        } else if (matrixA[0].length != matrixB[0].length) {
            return null;
        }

        double[][] result = new double[matrixA.length][matrixA.length];

        for (int i = 0; i < matrixA.length; i++) {
            for (int j = 0; j < matrixA.length; j++) {
                result[i][j] = matrixA[i][j] + matrixB[i][j];
            }
        }

        return result;
    }
}
