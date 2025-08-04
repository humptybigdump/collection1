package task1;

public class Cell {
    private static final String START = "🟩";
    private static final String GOAL = "🟥";
    private static final String EMPTY = "⬜";
    private static final String OBSTACLE = "⬛";
    private static final String VISITED = "🟦";
    private static final String DESTINATION_REACHED = "🟪";

    private String representation;

    public Cell(String representation) {
        this.representation = representation;
    }

    public String getRepresentation() {
        return representation;
    }

    public boolean isEmpty() {
        return representation.equals(EMPTY);
    }

    public boolean isObstacle() {
        return representation.equals(OBSTACLE);
    }

    public boolean isStart() {
        return representation.equals(START);
    }

    public boolean isGoal() {
        return representation.equals(GOAL) | representation.equals(DESTINATION_REACHED);
    }

    public boolean isVisited() {
        return representation.equals(VISITED);
    }

    public void visit() {
        if (isGoal()) {
            representation = DESTINATION_REACHED;
        } else if (isEmpty()) {
            representation = VISITED;
        }
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (this.getClass() != obj.getClass()) return false;

        Cell other = (Cell) obj;
        return this.representation.equals(other.representation);
    }

    @Override
    public int hashCode() {
        return representation.hashCode();
    }

    @Override
    public String toString() {
        return representation;
    }

    public static Cell emptyCell() {
        return new Cell(EMPTY);
    }

    public static Cell obstacleCell() {
        return new Cell(OBSTACLE);
    }

    public static Cell startCell() {
        return new Cell(START);
    }

    public static Cell goalCell() {
        return new Cell(GOAL);
    }
}
