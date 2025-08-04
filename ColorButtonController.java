package edu.kit.aifb.proksy.colorButtonFrame.controller;

import java.awt.event.*;

import edu.kit.aifb.proksy.colorButtonFrame.model.ColorButton;
import edu.kit.aifb.proksy.colorButtonFrame.view.ButtonFrame;

/**
 * In dieser Klasse wird ein ActionListener implementiert, mit dem die
 * Hintergrundfarbe der Eventquelle geändert werden kann.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class ColorButtonController {
	private ButtonFrame frame;

	/**
	 * Erzeugt ein neues ColorListener Objekt und gibt es zurück
	 * 
	 * @return neues ColorListener-Objekt
	 */
	public ColorListener createColorListener() {
		return new ColorListener();
	}

	/**
	 * Verknüpft den Controller mit dem zugehörigen View
	 * 
	 * @param frame
	 */
	public void setView(ButtonFrame frame) {
		this.frame = frame;
	}

	/**
	 * Diese innere Klasse implementiert das ActionListener-Interface, kann also
	 * verwendet werden, um Benutzerinteraktion mit dem GUI zu verarbeiten. Sie soll
	 * sich um Ereignisse des ColorButtons kümmern
	 * 
	 * @author Janna
	 *
	 */
	class ColorListener implements ActionListener {
		/**
		 * Diese Methode überschreibt die Methode actionPerformed und wird aufgerufen,
		 * wenn der ColorButton betätigt wurde.
		 */
		@Override
		public void actionPerformed(ActionEvent e) {
			ColorButton eventSource = (ColorButton) e.getSource();
			eventSource.changeColor();
		}
	}
}
