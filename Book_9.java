package builder;

import java.util.List;

public class Book {

    private String title;
    private String author;
    private int releaseYear;
    private double price;
    private List<String> references;

    public Book(String title, String author, int releaseYear, double price, List<String> references) {
        this.title = title;
        this.author = author;
        this.releaseYear = releaseYear;
        this.price = price;
        this.references = references;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public void setReleaseYear(int releaseYear) {
        this.releaseYear = releaseYear;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setReferences(List<String> references) {
        this.references = references;
    }
}
