/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */

package edu.kit.kastel.dotsandboxes.logic;

import java.util.EnumSet;
import java.util.Set;

/**
 * A box of {@link DotsAndBoxes}.
 *
 * @author Programmieren-Team
 */
public class Box {
    
    private final Set<Direction> occupiedDirections = EnumSet.noneOf(Direction.class);
    private Player owner;

    /**
     * Sets an edge of this box being occupied by a player.
     * @param direction the direction of the edge
     * @param player the player occupying the edge
     * @return whether the edge has been occupied successfully
     */
    boolean occupy(Direction direction, Player player) {
        if (!occupiedDirections.add(direction)) {
            return false;
        }

        if (isClosed()) {
            owner = player;
        }

        return true;
    }

    /**
     * Returns whether all edges of this box are occupied.
     * @return whether all edges of this box are occupied
     */
    public boolean isClosed() {
        return occupiedDirections.size() == Direction.values().length;
    }

    /**
     * Returns the owner of this box being the player who occupied the last edge and closed it.
     * @return the owner of this box, {@code null} if it isn't closed yet
     */
    public Player getOwner() {
        return owner;
    }

    /**
     * Returns whether the edge in that direction is occupied.
     * @param direction the direction of the edge
     * @return {@code true} if the edge is occupied, {@code false} otherwise
     */
    public boolean isOccupied(Direction direction) {
        return occupiedDirections.contains(direction);
    }
}
