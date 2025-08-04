/**
* Instances of this class represent a play card for a card game.
*
* @Author Dominik Schaufelberger
*/
public class Card {
    private CardRank rank;
    private CardSuit suit;
    
    public Card(CardRank rank, CardSuit suit) {
		this.rank = rank;
		this.suit = suit;
    }
    
    public CardRank getRank() {
        return rank;
    }

    public void setRank(CardRank rank) {
        this.rank = rank;
    }

    public CardSuit getSuit() {
        return suit;
    }

    public void setSuit(CardSuit suit) {
        this.suit = suit;
    }

	/*
	* Für was die @Override-Notation steht ist hier noch unwichtig.
	*/
    @Override
    public String toString() {
	String description = "Suit: " + suit.toString() + " / Rank: " + rank.toString() + "\n";
	
	return description;
    }
}
