/**
 * Enum representing the rank of a card. The card ranks range from 2 to 10, Jack, Queen, King and Ace.
 * Each rank has a priority determining which card rank dominate others.
 * 
 * <br>
 * <br>
 * 
 * The standard order is: 2 < 3 < 4 < 5 < 6 < 7 < 8 < 9 < 10 < Jack < Queen < King < Ace
 * 
 * @author Dominik Schaufelberger
 *
 */
public enum CardRank {
    TWO(2), THREE(3), FOUR(4), FIVE(5), SIX(6), SEVEN(7), EIGHT(8), NINE(9), TEN(10), JACK(11), QUEEN(12), KING(13), ACE(14);
    
    private int priority;

    private CardRank(int priority) {
    	this.priority = priority;
    }
    
    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }
}
