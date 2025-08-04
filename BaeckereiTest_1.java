package edu.kit.aifb.proksy.baeckerei;

/**
 * @author ProkSy-Team
 * @version 1.0
 * 
 *         Klasse zum Testen der Funktionalität.
 *
 */
public class BaeckereiTest {
	/**
	 * Erzeugt jeweils 10 Kunden und 10 Bäcker und startet nacheinander die Threads.
	 * Insgesamt sollen 100 Brote gebacken und auch verkauft werden.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		Baeckerei baeckerei = new Baeckerei();

		Kunde[] k = new Kunde[10];
		Baecker[] b = new Baecker[10];
		for (int i = 0; i < 10; i++) {
			k[i] = new Kunde("Kunde " + (i + 1), baeckerei);
			b[i] = new Baecker("Baecker " + (i + 1), baeckerei);
		}

		for (int i = 0; i < 10; i++) {
			k[i].start();
			b[i].start();
		}
	}
}