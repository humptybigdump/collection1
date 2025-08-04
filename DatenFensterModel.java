package edu.kit.aifb.proksy.datenFenster.model;

import java.text.*;
import java.util.*;

/**
 * Diese Klasse erstellt ein Datum, dass in verschiedenen Formaten angezeigt
 * werden kann.
 * 
 * @version 1.0
 * @author ProkSy-Team
 *
 */
public class DatenFensterModel {
	private Date datum;
	// verschiedene Darstellungsformate
	private static final SimpleDateFormat lang = new SimpleDateFormat("EEEE', 'd'. 'MMMM yyyy"),
			mittel = new SimpleDateFormat("EEEE', 'd'. 'MMMM"), kurz = new SimpleDateFormat("d '. ' MMMM");

	/**
	 * Die Methode gibt die default-Einstellung für das Datumsformat zurück.
	 * 
	 * @return datum
	 */
	public String changeDate() {
		datum = new Date();
		return lang.format(datum);
	}

	/**
	 * Die Methode gibt das Datum im vom Nutzer angefragten Format zurück.
	 * 
	 * @param index
	 * @return datum
	 */
	public String changeDate(int index) {
		datum = new Date();
		if (index == 0) {
			return lang.format(datum);
		} else if (index == 1) {
			return mittel.format(datum);
		} else
			return kurz.format(datum);
	}
}
