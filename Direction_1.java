/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */

package edu.kit.kastel.dotsandboxes.logic;

/**
 * The directions on the board.
 *
 * @author Programmieren-Team
 */
public enum Direction {

    /**
     * The direction upwards.
     */
    UP(0, 1),
    /**
     * The direction downwards.
     */
    DOWN(0, -1),
    /**
     * The direction to the left.
     */
    LEFT(-1, 0),
    /**
     * The direction to the right.
     */
    RIGHT(1, 0);
    
    private final int columnOffset;
    private final int rowOffset;

    Direction(int columnOffset, int rowOffset) {
        this.columnOffset = columnOffset;
        this.rowOffset = rowOffset;
    }

    /**
     * Returns the offset in a column when apllying this direction.
     * @return the offset in a column
     */
    public int getColumnOffset() {
        return columnOffset;
    }

    /**
     * Returns the offset in a row when applying this direction.
     * @return the offset in a row
     */
    public int getRowOffset() {
        return rowOffset;
    }

    /**
     * Returns the value considered to be the opposite direction of this value.
     * @return the opposite direction
     */
    public Direction opposite() {
        return switch (this) {
            case UP -> DOWN;
            case DOWN -> UP;
            case LEFT -> RIGHT;
            case RIGHT -> LEFT;
        };
    }

    /**
     * Returns the direction value based on its representation.
     * @param representation the representation of the desired value
     * @return the direction value, {@code null} if no value suits the given representation
     */
    public static Direction fromRepresentation(String representation) {
        for (Direction direction : values()) {
            if (direction.toString().toLowerCase().equals(representation)) {
                return direction;
            }
        }
        return null;
    }
}
