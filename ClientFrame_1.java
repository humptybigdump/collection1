package edu.kit.aifb.proksy.ErdkundeRMI.client.view;

import java.awt.*;
import javax.swing.*;
import javax.swing.border.EmptyBorder;
import edu.kit.aifb.proksy.ErdkundeRMI.client.controller.*;

/**
 * Klasse, die das Frame repräsentiert und erstellt
 * 
 * @author ProkSy-Team
 * @version 1.0
 */
public class ClientFrame extends JFrame {

	private ViewController controller;

	private Container c;
	private JPanel unten;
	private JPanel inhalt;
	private JPanel platz;
	private JPanel textfelder;
	private JTextArea beschreibung;
	private JTextField bundesland;
	private JTextField hauptstadt;
	private JLabel land;
	private JLabel stadt;
	private JButton tausch;
	private JButton start;

	/**
	 * Konstruktor des Frames; erstellt das Frame
	 */
	public ClientFrame() {

		c = getContentPane();
		c.setLayout(new BorderLayout(10, 10));
		((JPanel) c).setBorder(new EmptyBorder(10, 10, 10, 10));

		tausch = new JButton("< >");
		tausch.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 20));
		start = new JButton("Start");
		start.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 20));
		bundesland = new JTextField();
		hauptstadt = new JTextField();
		hauptstadt.setEditable(false);

		unten = new JPanel();
		unten.setLayout(new GridLayout(3, 1, 10, 10));
		inhalt = new JPanel();
		inhalt.setLayout(new BorderLayout(10, 10));
		platz = new JPanel();
		textfelder = new JPanel();
		textfelder.setLayout(new GridLayout(1, 3, 10, 10));

		beschreibung = new JTextArea("Dieses Tool kann Bundesländern Hauptstädte oder umgekehrt "
				+ "\nzuordnen. In das editierbare Textfeld kann ein Bundesland/ "
				+ "\neine Hauptstadt eingefügt werden. Beim Betätigen des " + "\n'Start'-Buttons wird das passende "
				+ "Gegenstück ergänzt.");
		beschreibung.setEditable(false);
		beschreibung.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 20));
		land = new JLabel("Bundesland");
		land.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 20));
		stadt = new JLabel("Hauptstadt");
		stadt.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 20));

		inhalt.add(land, BorderLayout.WEST);
		inhalt.add(stadt, BorderLayout.EAST);
		inhalt.add(textfelder, BorderLayout.SOUTH);

		textfelder.add(bundesland);
		textfelder.add(tausch);
		textfelder.add(hauptstadt);

		unten.add(inhalt);
		unten.add(platz);
		unten.add(start);

		c.add(beschreibung, BorderLayout.NORTH);
		c.add(unten, BorderLayout.SOUTH);

		setSize(600, 450);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setTitle("Erdkunde");
		setVisible(true);
	}

	/**
	 * Methode, mit der das Frame eine Instanz des ViewControllers zugeordnet
	 * bekommt. Setzt die ActionListener
	 * 
	 * @param controller
	 */
	public void setViewController(ViewController controller) {
		this.controller = controller;
		tausch.addActionListener(this.controller.createTauschListener());
		start.addActionListener(this.controller.createStartListener());
	}

	/**
	 * Gibt das JTextField Bundesland zurück
	 * 
	 * @return bundesland
	 */
	public JTextField getBundesland() {
		return bundesland;
	}

	/**
	 * Gibt das JTextField Hauptstadt zurück
	 * 
	 * @return hauptstadt
	 */
	public JTextField getHauptstadt() {
		return hauptstadt;
	}
}
