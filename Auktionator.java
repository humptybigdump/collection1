package edu.kit.aifb.proksy.auktion;

/**
 * Diese Klasse repräsentiert den Auktionator der Auktion
 * 
 * @author ProkSy-Team
 * @version 1.0
 * 
 */
public class Auktionator extends Thread {

	private Versteigerungsobjekt objekt;

	/**
	 * Konstruktor der Klasse
	 * 
	 * @param objekt
	 *            Referenz auf das zu versteigernde Objekt
	 */
	public Auktionator(Versteigerungsobjekt objekt) {
		super();
		this.objekt = objekt;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Thread#run()
	 */
	@Override
	public void run() {
		while (!objekt.isVerkauft()) {

			try {
				System.out.println("Auktionator: DREI");
				sleep(1000);
				System.out.println("Auktionator: ZWEI");
				sleep(1000);
				System.out.println("Auktionator: EINS");
				sleep(1000);
				objekt.verkaufen();
			} catch (InterruptedException e) {
			}

		}

	}

	/**
	 * Nimmt ein Gebot eines Bieters entgegen
	 * 
	 * @param bieter
	 *            Referenz auf den Bieter
	 */
	synchronized public void gebotEntgegenNehmen(Bieter bieter) {
		int neuesGebot = objekt.getHoechstgebot() + 1;
		System.out.println("Neues Gebot (" + bieter + "): " + neuesGebot);
		this.interrupt();
		objekt.gebotEintragen(bieter, neuesGebot);

		notifyAll();
		try {
			wait();
		} catch (InterruptedException e) {
		}

	}

	/**
	 * Getter-Methode für das zu versteigernde Objekt
	 * 
	 * @return das Versteigerungsobjekt
	 */
	public Versteigerungsobjekt getObjekt() {
		return objekt;
	}

}
