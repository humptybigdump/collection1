package edu.kit.aifb.proksy.baeckerei;

/**
 * @author ProkSy-Team
 * @version 1.0
 * 
 *         Die Klasse simuliert eine Bäckerei, welche eine begrenzten Lagerraum
 *         für Brote besitzt.
 *
 */
public class Baeckerei {
	private int anzahlBrote = 0;
	private int maxBrote = 10;

	public void kaufeBrot(String threadName) {
		anzahlBrote = anzahlBrote - 1;
		System.out.println("Bestand Brote: " + anzahlBrote + " - Vorgang: Verkauf an " + threadName);
	}

	public void backeBrot(String threadName) {
		anzahlBrote = anzahlBrote + 1;
		System.out.println("Bestand Brote: " + anzahlBrote + " - Vorgang: Backen von " + threadName);
	}
}
