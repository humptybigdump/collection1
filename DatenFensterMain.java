package edu.kit.aifb.proksy.datenFenster.main;

import edu.kit.aifb.proksy.datenFenster.controller.*;
import edu.kit.aifb.proksy.datenFenster.model.*;
import edu.kit.aifb.proksy.datenFenster.view.*;

/**
 * Diese KLasse enthält die main-Methode, aus der heraus das anzuzeigende
 * Fenster und der Controller erzeugt werden und die beiden miteinander bekannt
 * gemacht werden.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class DatenFensterMain {

	private static DatenFensterController controller;
	private static DatenFensterModel model;
	private static DatenFensterView view;

	/**
	 * Main-Methode der Klasse
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		// Erzeugt ein Objekt vom Typ Model, das später dem View übergeben wird
		// (für default-Einstellung)
		model = new DatenFensterModel();
		// Controller und View werden erzeugt
		controller = new DatenFensterController();
		view = new DatenFensterView(model);
		// Das Fenster wird sichtbar gemacht
		view.setVisible(true);
		// View und Controller werden miteinander bekannt gemacht
		view.setController(controller);
		controller.setView(view);
	}
}
