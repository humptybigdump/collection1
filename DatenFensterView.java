package edu.kit.aifb.proksy.datenFenster.view;

import java.awt.*;

import javax.swing.*;

import edu.kit.aifb.proksy.datenFenster.controller.*;
import edu.kit.aifb.proksy.datenFenster.model.*;

/**
 * Diese Klasse erzeugt ein Fenster, in dem ein Datum in verschiedenen Formaten
 * angezeigt werden kann.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class DatenFensterView extends JFrame {
	// Variablen für graphische Oberfläche
	private JLabel beschriftung, datumsAnzeige;
	private JComboBox<String> formatAuswahl;

	/**
	 * Konstruktor des Views;
	 * 
	 * @param model
	 */
	public DatenFensterView(DatenFensterModel model) {
		// Allgemeine Einstellungen
		setTitle("DatumFrame");
		setSize(400, 400);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setFont(new Font("Helvetica", Font.BOLD, 28));

		// Initialisierung der einzelnen Bausteine
		beschriftung = new JLabel("Heutiges Datum:", JLabel.CENTER);
		// datum = new Date();
		datumsAnzeige = new JLabel(model.changeDate(), JLabel.CENTER); // default Einstellung der Datumsanzeige
		formatAuswahl = new JComboBox<String>();
		formatAuswahl.addItem("Alles anzeigen");
		formatAuswahl.addItem("Wochentag, Tag und Monat");
		formatAuswahl.addItem("Tag und Monat");

		// Hinzufügen der einzelnen Bausteine auf den Container
		setLayout(new BorderLayout());
		add(beschriftung, BorderLayout.NORTH);
		add(datumsAnzeige, BorderLayout.CENTER);
		add(formatAuswahl, BorderLayout.SOUTH);
	}

	/**
	 * Liefert eine Referenz auf die datumsAnzeige zurück.
	 * 
	 * @return datumsAnzeige
	 */
	public JLabel getLabel() {
		return datumsAnzeige;
	}

	/**
	 * Diese Methode verknüpft das View mit dem zugehörigen Controller.
	 * 
	 * @param controller
	 */
	public void setController(DatenFensterController controller) {
		formatAuswahl.addItemListener(controller);
	}

}
