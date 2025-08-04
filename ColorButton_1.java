package edu.kit.aifb.proksy.colorButtonFrame.model;

import java.awt.*;
import javax.swing.*;

/**
 * Diese Klasse erzeugt die zufällige Hntergrundfarbe eines Buttons.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class ColorButton extends JButton {
	/**
	 * Konstruktor der Klasse; erzeugt ein ColorButton Objekt mit Text und
	 * zufälliger Hintergrundfarbe.
	 * 
	 * @param text
	 */
	public ColorButton(String text) {
		super(text);
		// Hintergrund soll nicht durchsichtig sein
		setOpaque(true);
		// Bei MacOS notwendig, um den Effekt der Änderung sichtbar zu machen
		// Unter Windows optional
		setBorderPainted(false);
		changeColor();
	}

	/**
	 * Diese Methode erzeugt eine zufällige Hintergrundfarbe.
	 */
	public void changeColor() {
		Color f = new Color((float) Math.random(), (float) Math.random(), (float) Math.random());
		setBackground(f);
		String s = "(" + f.getRed() + "," + f.getGreen() + "," + f.getBlue() + ")";
		setToolTipText(s);
	}
}