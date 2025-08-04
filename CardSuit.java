/**
 * Enum representing the card's suit (sign/color). The suits are designed by the 'french design'
 * (See <a href=http://en.wikipedia.org/wiki/Playing_card#French_design>http://en.wikipedia.org/wiki/Playing_card#French_design</a>)
 * 
 * <br>
 * <br>
 * 
 * The represented suits are: clubs, diamonds, hearts and spades.
 * 
 * @author Dominik Schaufelberger
 *
 */
public enum CardSuit {
    CLUBS, DIAMONDS, HEARTS, SPADES;

	/*
	* Auch hier ist die @Override-Notation wieder nicht von belang. Was das switch-Konstrukt macht werden wir
	* warscheinlich nächste Woche sehen. Wichtig hierbei ist gerade nur: Für jedes enum-Attribut wird der entsprechende
	* String zurückgegeben.
	*/
    @Override
    public String toString() {
		String description;
		
		switch (this) {
		case CLUBS:
		    description = "Clubs";
		    break;
		case DIAMONDS:
		    description = "Diamonds";
		    break;
		case HEARTS:
		    description = "Hearts";
		    break;
	
		default: description = "Spades";
		    break;
	}
	
	return description;
    }
}
