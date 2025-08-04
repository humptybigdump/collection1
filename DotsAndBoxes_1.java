/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */

package edu.kit.kastel.dotsandboxes.logic;

import java.util.List;

/**
 * This class represents a running game of {@code Dots And Boxes}.
 * Here connecting two dots is considered the same as choosing an edge of a box.
 *
 * @author Programmieren-Team
 */
public class DotsAndBoxes {

    private final Box[][] boxes;
    private int numberOfFreeEdges;
    private Player currentPlayer;
    private Player winner;
    private final List<Player> players;

    /**
     * Creates a new instance of a game. Side length representing how many boxes will be in each row/column, must not be negative.
     *
     * @param length      the side length of the game
     * @param players the players attending the game
     */
    public DotsAndBoxes(int length, Player... players) {
        this.boxes = new Box[length][length];
        for (int column = 0; column < length; column++) {
            for (int row = 0; row < length; row++) {
                this.boxes[column][row] = new Box();
            }
        }

        /*
        2(n²+n) = 4n + 2n(n-1) = (outer edges + inner edges)   with n being the length of the game
          with inner edges = (vertically + horizontally) the edges of one side of each box of a line
            (one line of boxes must be omitted because its edges would be outer edges)
        */
        this.numberOfFreeEdges = 2 * (boxes.length * boxes.length + boxes.length);
        
        this.players = List.of(players);
        resetCurrentPlayer();
    }

    /**
     * Resets the current player to the first player.
     */
    void resetCurrentPlayer() {
        currentPlayer = players.get(0);
    }

    /**
     * Returns the player whose turn it is.
     * @return the player whose turn it is
     */
    public Player getCurrentPlayer() {
        return currentPlayer;
    }

    /**
     * Sets a line on the board. The line is represented by the edge of a box.
     * Since there might be two ways to indicate the same edge (e. g. the bottom of a box is the same as the top of the box below)
     * choosing either one yields the same effect.
     * Position components are 0-indexed.
     * @param column the column of the box
     * @param row the row of the box
     * @param direction the direction of the border of the box
     * @return whether setting the line was successful
     */
    public boolean setBoxSide(int column, int row, Direction direction) {
        if (column < 0 || column >= boxes.length || row < 0 || row >= boxes.length) {
            return false;
        }

        if (setBoxSideInternal(column, row, direction)) {
            if (causedBoxClosing(column, row, direction)) {
                currentPlayer.incrementScore();

                if (isFinished()) {
                    winner = calculateWinner();
                }
            } else {
                currentPlayer = players.get((players.indexOf(currentPlayer) + 1) % players.size());
            }
            return true;
        }
        return false;
    }

    private boolean causedBoxClosing(int column, int row, Direction direction) {
        return boxes[column][row].isClosed() 
                || (!crossesBorder(direction, column, row)
                    && boxes[column + direction.getColumnOffset()][row + direction.getRowOffset()].isClosed());
    }

    private Player calculateWinner() {        
        Player playerHighestScore = null;
        for (Player player : players) {
            if (playerHighestScore == null) {
                playerHighestScore = player;
                continue;
            }
            
            if (player.getScore() < playerHighestScore.getScore()) {
                playerHighestScore = player;
            }
        }
        return playerHighestScore;
    }

    private boolean setBoxSideInternal(int column, int row, Direction direction) {
        if (boxes[column][row].occupy(direction, currentPlayer)
                && (crossesBorder(direction, column, row)
                    || boxes[column + direction.getColumnOffset()][row + direction.getRowOffset()]
                        .occupy(direction.opposite(), currentPlayer))) {
            numberOfFreeEdges--;
            return true;
        }
        return false;
    }

    private boolean crossesBorder(Direction direction, int column, int row) {
        return column + direction.getColumnOffset() < 0
                || column + direction.getColumnOffset() >= boxes.length
                || row + direction.getRowOffset() < 0
                || row + direction.getRowOffset() >= boxes.length;
    }

    /**
     * Returns whether the game is finished.
     * @return whether the game is finished
     */
    public boolean isFinished() {
        return numberOfFreeEdges == 0;
    }

    /**
     * Returns the winner of the game.
     * @return the winner of the game, {@code null} if the game isn't finished yet
     */
    public Player getWinner() {
        return winner;
    }

    /**
     * Returns the side length of the board.
     * @return the side length of the board
     */
    public int getLength() {
        return boxes.length;
    }

    /**
     * Returns the box indicated by its position on the board. Position components are 0-indexed.
     * @param column the column of the box
     * @param row the row of the box
     * @return the box on the board
     */
    public Box get(int column, int row) {
        return boxes[column][row];
    }
}
