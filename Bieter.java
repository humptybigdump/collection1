package edu.kit.aifb.proksy.auktion;

/**
 * Diese Klasse repräsentiert einen Bieter auf einer Auktion
 * 
 * @author ProkSy-Team
 * @version 1.0
 * 
 */
public class Bieter extends Thread {

	private Auktionator auktionator;
	private String name;
	private int vorbehaltspreis;

	/**
	 * Konstruktor der Klasse Bieter
	 * 
	 * @param auktionator
	 *            Referenz auf den Auktionator, der die Auktion durchführt
	 * @param name
	 *            Name des Bieters
	 * @param vorbehaltspreis
	 *            Preis, bis zu dem der Bieter maximal bietet
	 */
	public Bieter(Auktionator auktionator, String name, int vorbehaltspreis) {
		super();
		this.auktionator = auktionator;
		this.name = name;
		this.vorbehaltspreis = vorbehaltspreis;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Thread#run()
	 */
	@Override
	public void run() {
		while (!auktionator.getObjekt().isVerkauft()) {
			if (auktionator.getObjekt().getHoechstgebot() < vorbehaltspreis
					& auktionator.getObjekt().getHoechstbietender() != this) {
				try {
					sleep(1500);
				} catch (InterruptedException e) {
				}
				auktionator.gebotEntgegenNehmen(this);

			}
		}

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Thread#toString()
	 */
	public String toString() {
		return name;
	}

}
