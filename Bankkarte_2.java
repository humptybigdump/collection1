package edu.kit.aifb.prog1.kapselung;

/**
 * Einführendes Beispiel modelliert eine einfache Bankkarte ohne Anwendung von
 * Kapselung bzw. Data Hiding.
 * 
 * @author Prog1-Team
 * @version 1.0
 */
public class Bankkarte {
	public int pin;
	public double guthaben;

	/**
	 * Konstruktor legt Werte der Instanzvariablen fest
	 * 
	 * @param pin      Passwort der Karte
	 * @param guthaben Startguthaben der Karte
	 */
	public Bankkarte(int pin, double guthaben) {
		this.pin = pin;
		this.guthaben = guthaben;
	}
}
