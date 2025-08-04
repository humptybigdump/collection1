package edu.kit.aifb.proksy.codeknacker;

import java.io.*;

/**
 * Die Main-Methode der Klasse sorgt dafür, dass eine Datei ausgelesen,
 * entschlüsselt und unter neuem Namen wieder gespeichert wird
 * 
 * @author ProkSy-Team
 * @version 1.0
 * 
 */
public class CodeKnackerMain {

	/**
	 * Main-Methode der Klasse
	 * 
	 * @param args Kommandozeilenargumente
	 */
	public static void main(String[] args) {

		// Datei einlesen
		File geheimnachricht = new File("geheimnachricht.txt");
		int verschiebung = CodeKnacker.analysiereDatei(geheimnachricht);
		String klartext = CodeKnacker.verschiebeTextInDatei(geheimnachricht, verschiebung);
		System.out.println("Empfohlene Verschiebung von Methode: " + verschiebung);
		System.out.println("Originaltext:  " + CodeKnacker.verschiebeTextInDatei(geheimnachricht, 0));
		System.out.println("Entschlüsselt: " + klartext);
		File klartextnachricht = new File("klartextnachricht.txt");
		BufferedWriter out = null;
		try {
			out = new BufferedWriter(new FileWriter(klartextnachricht));
			out.write(klartext);
			out.flush();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
