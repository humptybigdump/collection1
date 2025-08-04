package edu.kit.kastel.model;

/**
 * Describes the four cardinal directions in 2D space:
 * - up (i.e. north)
 * - down (i.e. south)
 * - left (i.e. west)
 * - right (i.e. east)
 *
 * @author Programmieren-Team
 */
public enum Direction {

    /**
     * The direction up (i.e. north), with the unit vector (0,-1).
     */
    UP(new Vector2D(0, -1), "up"),

    /**
     * The direction down (i.e. south), with the unit vector (0,1).
     */
    DOWN(new Vector2D(0, 1), "down"),

    /**
     * The direction left (i.e. west), with the unit vector (-1,0).
     */
    LEFT(new Vector2D(-1, 0), "left"),

    /**
     * The direction right (i.e. east), with the unit vector (1,0).
     */
    RIGHT(new Vector2D(1, 0), "right");

    private static final String ERROR_NOT_FOUND = "No corresponding Direction2D found for: '%s'";

    private final String representation;
    private final Vector2D unitVector;

    /**
     * Constructs a new direction.
     *
     * @param unitVector The unit vector
     * @param representation The String representation
     */
    Direction(Vector2D unitVector, String representation) {
        this.unitVector = unitVector;
        this.representation = representation;
    }

    /**
     * Returns the unit vector of this direction.
     * <p>
     * The unit vector of a direction is the vector that when added to a position
     * results in a new position exactly one unit of measurement away in the
     * direction of this direction.
     * <p>
     * The origin (0,0) is the upper left corner and the ordinate axis is oriented
     * downwards.
     *
     * @return the unit vector of this direction
     */
    public Vector2D getUnitVector() {
        return this.unitVector;
    }

    @Override
    public String toString() {
        return this.representation;
    }

    /**
     * Returns the direction represented by the given {@code vector}.
     *
     * @param vector the vector
     * @throws IllegalArgumentException if the {@code vector} does not match
     * @return the matching direction
     */
    public static Direction fromUnitVector(Vector2D vector) {
        for (Direction direction : Direction.values()) {
            if (direction.getUnitVector().equals(vector)) {
                return direction;
            }
        }
        throw new IllegalArgumentException(ERROR_NOT_FOUND.formatted(vector));
    }

    /**
     * Returns the direction represented by the given {@code string}.
     *
     * @param string the string
     * @throws IllegalArgumentException if the {@code string} does not match
     * @return the matching direction
     */
    public static Direction fromString(String string) {
        for (Direction direction : Direction.values()) {
            if (direction.toString().equals(string)) {
                return direction;
            }
        }
        throw new IllegalArgumentException(ERROR_NOT_FOUND.formatted(string));
    }
}
