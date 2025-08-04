package edu.kit.aifb.prog1.kapselung;

/**
 * Klasse inkl. main-Methode zum Testen der Bankkarte ohne Einsatz von Kapselung
 * 
 * @author Prog1-Team
 * @version 1.0
 */
public class Anwendung {

	public static void main(String[] args) {
		// Erzeugung einer neuen Instanz �ber Konstruktor
		Bankkarte karte = new Bankkarte(1234, 500);
		
		// Guthaben wird direkt ge�ndert
		karte.guthaben = karte.guthaben + 100;
		
		// Abfrage der Pin ohne Einschr�nkungen m�glich
		System.out.println("Pin: " + karte.pin);
	}

}
