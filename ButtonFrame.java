package edu.kit.aifb.proksy.colorButtonFrame.view;

import java.awt.*;
import javax.swing.*;

import edu.kit.aifb.proksy.colorButtonFrame.model.ColorButton;
import edu.kit.aifb.proksy.colorButtonFrame.controller.ColorButtonController;

/**
 * Diese Klasse erzeugt ein Fenster mit einem Button und einer zufälligen
 * Hintergrundfarbe.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class ButtonFrame extends JFrame {

	private ColorButtonController controller;
	private Container c;
	private ColorButton cb;

	/**
	 * Konstruktor der Klasse; erzeugt ein Fenster mit einem Colorbutton, der
	 * übergeben wird.
	 * 
	 * @param cb
	 */
	public ButtonFrame(ColorButton cb) {
		// allgemeines
		setTitle("Farbenwechsel");
		setSize(250, 250);
		setLocation(250, 0);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		c = getContentPane();
		// Initialisierung des ColorButtons
		this.cb = cb;
		// Hinzufügen des ColorButtons
		c.add(cb);
	}

	// Aufgabenteil b)
	/**
	 * Verknüft das View mit dem zugehörigen Controller
	 * 
	 * @param controller
	 */
	public void setController(ColorButtonController controller) {
		this.controller = controller;
		cb.addActionListener(this.controller.createColorListener());
	}

}
