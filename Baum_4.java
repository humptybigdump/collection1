package edu.kit.aifb.prog1.binaerBaum;

/**
 * Die Klasse Baum
 * 
 * @version 1.0
 * @author Prog1-Team
 */
public class Baum {

    /* HIER CODE EINFÜGEN !!! */

    public Baum(int x) {
        wert = x;
    }

    public Baum(int x, Baum links, Baum rechts) {
        wert = x;
        this.links = links;
        this.rechts = rechts;
    }

    /**
     * Fügt einen int-Wert nach dem Prinzip eines binären Suchbaums ein.
     * 
     * @param x int-Wert
     */
    public void insert(int x) {

        /* HIER CODE EINFÜGEN !!! */

    }

    public Baum baumSpiegeln() {
        return baumSpiegeln(this);
    }

    /**
     * Gibt einen neuen gespiegelten Baum zurück.
     * 
     * @param zuspiegeln Der zu spiegelnde Baum
     * @return Der neue gespiegelte Baum
     */
    public static Baum baumSpiegeln(Baum zuspiegeln) {

        /* HIER CODE EINFÜGEN !!! */

    }

    /**
     * Überprüft ob zwei Bäume gespiegelt sind.
     * 
     * @param baum1 Der erste Baum
     * @param baum2 Der zweite Baum
     * @return true wenn Bäume gespiegelt sind, false andernfalls
     */
    public static boolean sindGespiegelt(Baum baum1, Baum baum2) {

        /* HIER CODE EINFÜGEN !!! */

    }

    /**
     * Gibt an, ob der Baum symmetrisch ist.
     * 
     * @return true wenn symmetrisch, false andernfalls
     */
    public boolean istSymmetrisch() {

        /* HIER CODE EINFÜGEN !!! */

    }

    // Inorder-Traversierung (LWR)
    public String toString() {

        /* HIER CODE EINFÜGEN !!! */

    }

    /**
     * Gibt einen String für die Baumstruktur bezüglich einer gegebenen
     * Traversierungsreihenfolge zurück.
     * 
     * @param order "pre", "in" oder "post"
     * @return String
     */
    public String print(String order) {

        /* HIER CODE EINFÜGEN !!! */

    }

}
