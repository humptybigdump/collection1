package edu.kit.aifb.proksy.maiwanderung;

/**
 * Diese Klasse modelliert eine Bratwurst und ist eine Unterklasse von
 * Grillgut. Jedes Objekt besitzt einen Namen, welcher die genaue Speise festlegt.
 * 
 * @author ProkSy-Team
 * @version 1.0
 *
 */

public class Bratwurst extends Grillgut {
	/**
	 * Konstruktor legt Bezeichnung der Bratwurst fest.
	 * 
	 * @param bezeichnung Name der Bratwurst.
	 */
	public Bratwurst(String bezeichnung) {
		super(bezeichnung);
	}

}