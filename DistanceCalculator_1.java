/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */

package edu.kit.kastel.model;

/**
 * A class for calculating distances between vectors.
 *
 * @author Programmieren-Team, usxjc
 */
public final class DistanceCalculator {

    private static final int MIN_DEGREE = 1;
    private static final int MANHATTAN_DEGREE = 1;
    private static final int EUCLIDEAN_DEGREE = 2;

    private DistanceCalculator() {
        // utility class
    }

    /**
     * Calculates the Minkowski distance between two vectors. Both vectors must have the same length.
     *
     * @param vector the first vector
     * @param other the other vector
     * @param degree the degree of the Minkowski distance
     * @return the Minkowski distance between the two vectors
     */
    public static double getMinkowskiDistance(int[] vector, int[] other, int degree) {
        int p = Math.max(degree, MIN_DEGREE); // BUG: calculate max instead of min

        double distance = 0;

        // BUG: bad Code & distance wasn't set in if's

        for (int i = 0; i < vector.length; i++) {
            distance += Math.pow(Math.abs(vector[i] - other[i]), p);
        }
        distance = Math.pow(distance, 1.0 / p); // BUG: integer division


        return distance;
    }

    /**
     * Calculates the Manhattan distance between two vectors.
     *
     * @param vector the first vector
     * @param other the second vector
     * @return the Manhattan distance between the two vectors
     */
    public static double getManhattanDistance(int[] vector, int[] other) {
        return getMinkowskiDistance(vector, other, MANHATTAN_DEGREE); // NOT REALLY BUG: bad code
    }

    /**
     * Calculates the Euclidean distance between two vectors.
     *
     * @param vector the first vector
     * @param other the second vector
     * @return the Euclidean distance between the two vectors
     */
    public static double getEuclideanDistance(int[] vector, int[] other) {
        return getMinkowskiDistance(vector, other, EUCLIDEAN_DEGREE); // NOT REALLY BUG: bad code
    }
}
