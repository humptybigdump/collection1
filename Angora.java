package edu.kit.aifb.prog1;

/**
 * Musterloesung der Aufgabe p27
 *
 * @version 1.0
 * @author Prog1-Team
 */
public class Angora extends Hauskatze {
    public String getAbstammung() {
        String result = "";
        result = "Angora" + PFEIL + super.getAbstammung();
        return result;
    }
}
