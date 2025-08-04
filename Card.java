package strings;

public enum Card {
    ACE("Das Ass im Ärmel"),
    KING("Der tolle König"),
    QUEEN,
    JACK;

    private String phrase;

    Card(String phrase) {
        this.phrase = phrase;
    }

    // Default implementation uses the enums Name ("ACE" for an ace) as its phrase.
    Card() {
        this.phrase = this.name();
    }

    @Override
    public String toString() {
        return this.phrase;
    }


    public static void main(String[] args) {
        for (Card card : Card.values()) {
            System.out.println(card.name() + ": " + card);
        }
    }
}
