package edu.kit.aifb.prog1;

/**
 * Musterloesung der Aufgabe p27
 *
 * @version 1.0
 * @author Prog1-Team
 */
public class Dobermann extends Hund {
    public String getAbstammung() {
        String result = "";
        result = "Dobermann" + PFEIL + super.getAbstammung();
        return result;
    }
}
