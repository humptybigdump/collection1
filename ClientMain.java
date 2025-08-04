package edu.kit.aifb.proksy.Erdkunde.client.main;

import edu.kit.aifb.proksy.Erdkunde.client.controller.*;
import edu.kit.aifb.proksy.Erdkunde.client.view.*;
import edu.kit.aifb.proksy.Erdkunde.server.model.*;

/**
 * Diese Klasse enthält die main-Methode des Client
 * 
 * @author ProkSy-Team
 * @version 1.0
 *
 */
public class ClientMain {

	private static ClientFrame frame;
	private static ViewController viewController;
	private static ClientController clientController;

	/**
	 * main-Methode der Klasse
	 * 
	 * @param args Kommandozeilenargumente
	 */
	public static void main(String[] args) {
		frame = new ClientFrame();
		viewController = new ViewController();
		clientController = new ClientController();

		// hier werden Frame und ViewController miteinander bekannt gemacht
		frame.setViewController(viewController);
		viewController.setView(frame);

		// hier werden ClientController und ViewController miteinander bekannt gemacht
		viewController.setClientController(clientController);
		clientController.setViewController(viewController);

	}

}
