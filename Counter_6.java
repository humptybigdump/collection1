package edu.kit.aifb.prog1.debugging;

/**
 * Programm dient als einführendes Beispiel für den Umgang mit Stepping-Befehlen
 * beim Debugging.
 * 
 * @author Lukas Struppek
 * @version 1.0
 */
public class Counter {
	private int result = 0;

	/**
	 * Getter für Variable result
	 * 
	 * @return result
	 */
	public int getResult() {
		return result;
	}

	/**
	 * Methode soll Summe der Zahlen von 1 bis 100 berechnen. Berechnung allerdings
	 * fehlerhaft, da Instanzvariable result durch lokale Variable result überdeckt
	 * wird.
	 */
	public void count() {
		int result = 0;
		for (int i = 1; i <= 100; i++) {
			result = result + i;
		}
	}

	public static void main(String[] args) {
		Counter c = new Counter();
		c.count();
		System.out.println(c.getResult());
	}
}
