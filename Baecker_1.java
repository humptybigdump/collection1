package edu.kit.aifb.proksy.baeckerei;

/**
 * @author ProkSy-Team
 * @version 1.0
 * 
 *         Die Klasse ist eine Unterklasse von Thread und simuliert einen
 *         Bäcker. Dieser wird einer Bäckerei zugeordnet und backt für diese
 *         Brote, entspricht also einem Erzeuger.
 *
 */
public class Baecker extends Thread {
	private Baeckerei b;

	/**
	 * Konstruktor legt Bezeichnung des Bäckers fest und weist eine Bäckerei zu.
	 * 
	 * @param name Bezeichnung des Threads
	 * @param b    Zugewiesene Bäckerei
	 */
	public Baecker(String name, Baeckerei b) {
		super(name);
		this.b = b;
	}

	/**
	 * Der Bäcker backt 10 Brote pro Durchlauf. Nach jedem gebackenene Brot dauert
	 * es 100ms, bis das nächste Brot fertig gestellt wird.
	 */
	@Override
	public void run() {
		for (int i = 0; i < 10; i++) {
			b.backeBrot(this.getName());
			try {
				sleep(100);
			} catch (InterruptedException ie) {
			}
		}
	}

}
