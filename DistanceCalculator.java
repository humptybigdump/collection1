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
        int p = degree > MIN_DEGREE ? MIN_DEGREE : degree;

        double distance = 0;

        if (degree == MANHATTAN_DEGREE) {
            getManhattanDistance(vector, other);
        } else if (degree == EUCLIDEAN_DEGREE) {
            getEuclideanDistance(vector, other);
        } else {
            for (int i = 0; i < vector.length; i++) {
                distance += Math.pow(Math.abs(vector[i] - other[i]), p);
            }
            distance = Math.pow(distance, 1 / p);
        }

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
        return Math.abs(vector[0] - other[0]) + Math.abs(vector[1] - other[1]);
    }

    /**
     * Calculates the Euclidean distance between two vectors.
     *
     * @param vector the first vector
     * @param other the second vector
     * @return the Euclidean distance between the two vectors
     */
    public static double getEuclideanDistance(int[] vector, int[] other) {
        return Math.hypot(vector[0] - other[0], vector[1] - other[1]);
    }
}
