package chesspieces;

import java.util.ArrayList;

/**
 * Implements an abstract chess piece.
 * Specific types of chess pieces inherit from this class.
 *
 * @author uhnru
 */
public abstract class ChessPiece {
    private Position position;
    private final String color;

    /**
     * Creates a chess piece in a chess board.
     *
     * @param column the starting column of the chess piece.
     * @param row the starting row of the chess piece.
     * @param color the color of the chess piece.
     */
    public ChessPiece(int column, int row, String color) {
        this.position = new Position(column, row);
        this.color = color;
    }

    /**
     * Gets the current position of the chess piece.
     *
     * @return the current position of the chess piece.
     */
    public Position getPosition() {
        return position;
    }

    /**
     * Gets the color of the chess piece.
     *
     * @return the color of the chess piece.
     */
    public String getColor() {
        return color;
    }

    /**
     * Checks whether a move is valid from the chess piece's list of valid moves.
     *
     * @param position the checked position.
     * @return {@code true} if the position is valid, {@code false} otherwise.
     */
    public boolean isValidMove(Position position) {
        return getValidMoves().contains(position);
    }

    /**
     * Gets the valid moves of the chess piece.
     *
     * @return all valid moves of the chess piece.
     */
    public abstract ArrayList<Position> getValidMoves();
}
