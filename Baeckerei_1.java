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

	/**
	 * Methode prüft zunächst, ob ein Brot für den Verkauf zur Verfügung steht. Ist
	 * dies nicht der Fall, wird der aufrufende Thread in einen Wartezustand
	 * versetzt.
	 * 
	 * Ist ein Brot zum Verkauf verfügbar, so wird die Anzahl der Brote um 1
	 * vermindert und die wartenden Threads über eine Änderung informiert.
	 * 
	 * @param threadName Bezeichnung des aufrufenden Threads
	 */
	public synchronized void kaufeBrot(String threadName) {
		while (anzahlBrote <= 0) {
			try {
				wait();
			} catch (InterruptedException ie) {
			}
		}
		anzahlBrote = anzahlBrote - 1;
		notifyAll();
		System.out.println("Bestand Brote: " + anzahlBrote + " - Vorgang: Verkauf an " + threadName);
	}

	/**
	 * Methode prüft zunächst, ob ausreichend Lagerkapazität für ein zusätzliches
	 * Brot zur Verfügung steht. Ist dies nicht der Fall, wird der aufrufende Thread
	 * in einen Wartezustand versetzt.
	 * 
	 * Ist freie Kapazität verfügbar, so wird die Anzahl der Brote um 1 erhöht und
	 * die wartenden Threads über eine Änderung informiert.
	 * 
	 * @param threadName Bezeichnung des aufrufenden Threads
	 */
	public synchronized void backeBrot(String threadName) {
		while (anzahlBrote >= maxBrote) {
			try {
				wait();
			} catch (InterruptedException ie) {
			}
		}

		anzahlBrote = anzahlBrote + 1;
		notifyAll();
		System.out.println("Bestand Brote: " + anzahlBrote + " - Vorgang: Backen von " + threadName);
	}
}
