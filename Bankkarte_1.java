package edu.kit.aifb.prog1.klassenmethoden_klassenvariablen;

/**
 * Klasse stellt Anwendungsfall einer Klassenvariablen zur Festlegung von
 * eindeutigen Kontonummern dar.
 * 
 * @author Prog1-Team
 * @version 1.0
 */
public class Bankkarte {
	private int pin;
	private double guthaben;
	private long kontonr;
	/**
	 *  Bestimmt die Kontonummer der nächsten Instanz einer Bankkarte
	 */
	private static long zaehler = 1000000;

	/**
	 * Konstruktor der Klasse Bankkarte
	 * 
	 * @param pin      Zu setzende Pin
	 * @param guthaben Anfangsguthaben
	 */
	public Bankkarte(int pin, double guthaben) {
		// Zugriff auch ohne Angabe der Klasse möglich
		this.kontonr = Bankkarte.zaehler++;
		this.pin = pin;
		this.guthaben = guthaben;
	}

	/**
	 * Standard-Getter für Kontonummer
	 * 
	 * @return kontonummer
	 */
	public long getKontonr() {
		return this.kontonr;
	}
}
