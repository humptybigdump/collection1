package edu.kit.aifb.proksy.colorButtonFrame.main;

import javax.swing.JFrame;

import edu.kit.aifb.proksy.colorButtonFrame.view.ButtonFrame;
import edu.kit.aifb.proksy.colorButtonFrame.model.ColorButton;
import edu.kit.aifb.proksy.colorButtonFrame.controller.ColorButtonController;

/**
 * Diese KLasse enthält die main-Methode, aus der heraus das anzuzeigende
 * Fenster und der Controller erzeugt wird und die beiden miteinander bekannt
 * gemacht werden
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class ColorButtonMain {

	private static ButtonFrame view;
	private static ColorButtonController controller;
	private static ColorButton button;

	/**
	 * main-Methode der Klasse
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		// Erzeuge ein Model-Objekt, dass dem View später übergeben wird
		button = new ColorButton("");
		// Erzeuge einen Controller und ein View
		controller = new ColorButtonController();
		view = new ButtonFrame(button);
		// Mache Controller und View miteinander bekannt
		view.setController(controller);
		controller.setView(view);
		// Mache das Fenster sichtbar
		view.setVisible(true);
	}

}
