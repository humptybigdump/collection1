package edu.kit.aifb.prog1.kapselung;

/**
 * Klasse zeigt Anwendung der Klasse Bankkarte nach deren Anpassung bzgl. des
 * Data Hidings.
 * 
 * @author Lukas Struppek
 * @version 1.0
 */
public class Anwendung_Data_Hiding {
	public static void main(String[] args) {
		Bankkarte_Data_Hiding karte = new Bankkarte_Data_Hiding(1234, 500);

		// The field Bankkarte.guthaben is not visible
		karte.guthaben = karte.guthaben + 100;

		// The field Bankkarte.pin is not visible
		System.out.println("Pin: " + karte.pin);

		// Korrekte Zugriff auf private Eigenschaften über öffentliche Instanzmethoden
		karte.pinAendern(1234, 8765);
		karte.abheben(8765, 100);
	}
}
