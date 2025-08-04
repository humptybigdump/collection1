package edu.kit.aifb.proksy.listenerDemo.separateKlasse;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * ActionListener für Variante 3
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class ButtonListener implements ActionListener {

    private Uhrzeit3 uhrzeitView;

    /**
     * Konstruktor
     * 
     * @param uhrzeitView
     *            Referenz auf View
     */
    public ButtonListener(Uhrzeit3 uhrzeitView) {
	this.uhrzeitView = uhrzeitView;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
     */
    @Override
    public void actionPerformed(ActionEvent e) {
	SimpleDateFormat sdf = new SimpleDateFormat("HH':'mm':'ss' Uhr'");
	uhrzeitView.getLblUhrzeit().setText(sdf.format(new Date()));
    }

}
