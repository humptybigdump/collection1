package builder;

import java.util.ArrayList;
import java.util.List;

public class BookBuilder {

    private String title;
    private String author;
    private int releaseYear;
    private double price;
    private List<String> references;

    public BookBuilder() {
        this.references = new ArrayList<>();
    }

    public BookBuilder withTitle(String title) {
        this.title = title;
        return this;
    }

    public BookBuilder releasedIn(int year) {
        this.releaseYear = year;
        return this;
    }

    public BookBuilder by(String author) {
        this.author = author;
        return this;
    }

    public BookBuilder withCostsOf(double costs) {
        this.price = costs;
        return this;
    }

    public BookBuilder referringTo(String reference) {
        this.references.add(reference);
        return this;
    }

    public Book build() {
        return new Book(title, author, releaseYear, price, references);
    }
}
