package edu.kit.aifb.proksy.datenFenster.controller;

import java.awt.event.*;
import javax.swing.*;

import edu.kit.aifb.proksy.datenFenster.model.*;
import edu.kit.aifb.proksy.datenFenster.view.*;

/**
 * Die Klasse DatenFensterController reagiert auf Nutzereingaben im zugehörigen
 * View und verarbeitet diese.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */

public class DatenFensterController implements ItemListener {

	private DatenFensterView view;
	private DatenFensterModel model;
	private JLabel label;

	/**
	 * Diese Methode verknüpft den Controller mit dem zugehörigen View.
	 * 
	 * @param view
	 */
	public void setView(DatenFensterView view) {
		this.view = view;
		label = view.getLabel();
	}

	/**
	 * Diese Methode überschreibt die Methode itemStateChanged Die Methode wird
	 * aufgerufen, wenn das Item einer JComboBox, die eine Instanz dieser Klasse als
	 * Listener zugeordnet bekommen hat, geändert wird.
	 * 
	 * @param ie
	 */
	@Override
	public void itemStateChanged(ItemEvent ie) {
		model = new DatenFensterModel();
		JComboBox<String> source = (JComboBox<String>) ie.getSource();

		label.setText(model.changeDate(source.getSelectedIndex()));
	}
}
