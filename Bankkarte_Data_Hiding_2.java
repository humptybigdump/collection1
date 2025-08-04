package edu.kit.aifb.prog1.kapselung;

/**
 * 
 * @author Lukas Struppek
 * @version 1.0
 */
public class Bankkarte_Data_Hiding {
	private int pin;
	private double guthaben;

	/**
	 * Konstruktor legt Werte der Instanzvariablen fest
	 * 
	 * @param pin      Passwort der Karte
	 * @param guthaben Startguthaben der Karte
	 */
	public Bankkarte_Data_Hiding(int pin, double guthaben) {
		this.pin = pin;
		this.guthaben = guthaben;
	}

	/**
	 * Methode realisiert einen Prozess zum Geldabheben, bei welchem der aktuelle
	 * Kontostand betrachtet wird. Negativer Kontostand ist nicht möglich.
	 * 
	 * @param pin    Aktuelle Pin der Karte
	 * @param betrag Abzuhebender Betrag
	 * @return Auszahlung des Betrags
	 */
	public double abheben(int pin, int betrag) {
		if (this.pin == pin) {
			if (guthaben > betrag) {
				guthaben = guthaben - betrag;
				return betrag;
			}
		}
		return 0;
	}

	/**
	 * Methode dient zum Ändern der Pin. Nur möglich, wenn zuvor die alte Pin
	 * korrekt eingegeben worden ist. Neue Pin muss sich im Wertebereich von 1000
	 * bis 9999 befinden.
	 * 
	 * @param alt Alte Pin
	 * @param neu Neue Pin
	 */
	public void pinAendern(int alt, int neu) {
		if (pin == alt)
			if (neu >= 1000 && neu <= 9999)
				pin = neu;
	}

}