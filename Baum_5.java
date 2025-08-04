package edu.kit.aifb.prog1.binaerBaum;

/**
 * Die Klasse Baum
 * 
 * @version 1.0
 * @author Prog1-Team
 */
public class Baum {

    // Inhalt
    private int wert;
    // Verweis auf linken Teilbaum
    private Baum links;
    // Verweis auf rechten Teilbaum
    private Baum rechts;

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
        // im linken Ast einfuegen
        if (x < wert) {
            if (links == null)
                links = new Baum(x);
            else
                links.insert(x);
        }
        // im rechten Ast einfuegen
        else {
            if (rechts == null)
                rechts = new Baum(x);
            else
                rechts.insert(x);
        }
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
        Baum gespiegelt = new Baum(zuspiegeln.wert);
        if (zuspiegeln.rechts != null)
            gespiegelt.links = baumSpiegeln(zuspiegeln.rechts);
        if (zuspiegeln.links != null)
            gespiegelt.rechts = baumSpiegeln(zuspiegeln.links);
        return gespiegelt;
    }

    /**
     * Überprüft ob zwei Bäume gespiegelt sind.
     * 
     * @param baum1 Der erste Baum
     * @param baum2 Der zweite Baum
     * @return true wenn Bäume gespiegelt sind, false andernfalls
     */
    public static boolean sindGespiegelt(Baum baum1, Baum baum2) {
        // Leere Bäume zählen als gespiegelt
        if (baum1 == null && baum2 == null)
            return true;
        /*
         * Bäume sind gespiegelt, wenn die folgenden Bedingungen erfüllt sind:
         * 
         * 1. Der Wert beider Bäume ist gleich
         * 
         * 2. Linker Unterbaum des ersten Baumes ist das Spiegelbild des rechten
         * Unterbaumes des zweiten Baumes.
         * 
         * 3. Rechter Unterbaum des ersten Baumes ist das Spiegelbild des linken
         * Unterbaumes des zweiten Baumes.
         *
         */

        if (baum1 != null && baum2 != null && baum1.wert == baum2.wert)
            return (sindGespiegelt(baum1.links, baum2.rechts) && sindGespiegelt(baum1.rechts, baum2.links));

        return false;
    }

    /**
     * Gibt an, ob der Baum symmetrisch ist.
     * 
     * @return true wenn symmetrisch, false andernfalls
     */
    public boolean istSymmetrisch() {
        return sindGespiegelt(links, rechts);
    }

    // Inorder-Traversierung (LWR)
    public String toString() {
        String s = "";
        if (links != null) {
            s = s + links.toString();
            s = s + ", ";
        }

        s = s + wert;

        if (rechts != null) {
            s = s + ", ";
            s = s + rechts.toString();
        }
        return s;
    }

    /**
     * Gibt einen String für die Baumstruktur bezüglich einer gegebenen
     * Traversierungsreihenfolge zurück.
     * 
     * @param order "pre", "in" oder "post"
     * @return String
     */
    public String print(String order) {
        String s = "";
        if (order == "pre")
            s = s + wert;

        if (links != null) {
            if (order == "pre")
                s = s + ", ";
            s = s + links.print(order);
            if (order == "post" || order == "in")
                s = s + ", ";
        }

        if (order == "in")
            s = s + wert;

        if (rechts != null) {
            if (order == "pre" || order == "in")
                s = s + ", ";
            s = s + rechts.print(order);
            if (order == "post")
                s = s + ", ";
        }

        if (order == "post")
            s = s + wert;

        return s;
    }

}
