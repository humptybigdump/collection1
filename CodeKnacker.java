package edu.kit.aifb.proksy.codeknacker;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.StreamTokenizer;

/**
 * Diese Klasse stellt Klassenmethoden zur Verfügung, die beim Entschlüsseln von
 * Geheimtexten helfen
 * 
 * @author ProkSy-Team
 * @version 1.0
 * 
 */
public class CodeKnacker {

	/**
	 * Diese Methode verschiebt die Buchstaben eines Worten um den angegebenen Wert
	 * 
	 * @param wort         zu bearbeitendes Wort
	 * @param verschiebung Weite der Verschiebung
	 * @return bearbeitetes Wort
	 */
	public static String verschiebeWort(String wort, int verschiebung) {
		while (verschiebung < 0) {
			verschiebung = verschiebung + 26;
		}
		char buchstaben[] = wort.toUpperCase().toCharArray();
		String wortNachher = "";
		for (char buchstabe : buchstaben) {
			char buchstabeNachher = (char) (((((int) buchstabe - 65) + verschiebung) % 26) + 65);
			wortNachher += buchstabeNachher;
		}
		return wortNachher;
	}

	/**
	 * Diese Methode gibt den häufigsten Buchstaben einer Zeichenkette zurück
	 * 
	 * @param nachricht zu untersuchende Zeichenkette
	 * @return häufigster Buchstabe
	 */
	public static char haeufigsterBuchstabe(String nachricht) {
		char buchstaben[] = nachricht.toUpperCase().toCharArray();
		int haeufigkeiten[] = new int[26];
		for (char buchstabe : buchstaben) {
			if (buchstabe >= 65 & buchstabe <= 90) {
				haeufigkeiten[buchstabe - 65]++;
			}
		}
		int maxValue = 0;
		char haeufigsterBuchstabe = 0;
		for (int i = 0; i < haeufigkeiten.length; i++) {
			if (haeufigkeiten[i] > maxValue) {
				maxValue = haeufigkeiten[i];
				haeufigsterBuchstabe = (char) (i + 65);
			}
		}
		return haeufigsterBuchstabe;
	}

}
