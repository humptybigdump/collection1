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

	/**
	 * Diese Methode analysiert den Text, der in der übergebenen Datei enthalten
	 * ist(nur die erste Zeile).
	 * 
	 * @param datei Datei, die analysiert werden soll
	 * @return die vermutete Verschiebung zwischen
	 */
	public static int analysiereDatei(File datei) {

		System.out.println("Analysiere Datei " + datei.getName() + "...");
		String inhalt = "";
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(datei));
			inhalt = reader.readLine();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return ((int) 'E' - (int) CodeKnacker.haeufigsterBuchstabe(inhalt));
	}

	/**
	 * Diese Methode liest eine Datei aus und erzeugt einen String, der den Text aus
	 * der Datei um einen Wert verschoben enthält
	 * 
	 * @param datei        Datei, aus der gelesen werden soll
	 * @param verschiebung Weite der Verschiebung
	 * @return verschobene Zeichenkette
	 */
	public static String verschiebeTextInDatei(File datei, int verschiebung) {
		String ausgabe = "";
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(datei));
			StreamTokenizer st = new StreamTokenizer(reader);

			boolean stop = false;
			do {
				switch (st.nextToken()) {
				case StreamTokenizer.TT_NUMBER:
					ausgabe += ((int) st.nval == 0 ? "." : (int) st.nval);
					break;
				case StreamTokenizer.TT_WORD:
					ausgabe += CodeKnacker.verschiebeWort(st.sval, verschiebung);
					break;
				case StreamTokenizer.TT_EOF:
					stop = true;
					break;
				}
				ausgabe += " ";
			} while (!stop);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		return ausgabe;
	}

}
