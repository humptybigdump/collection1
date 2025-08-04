package edu.aifb.kit.struppek.sudoku;

/**
 * In dieser Klasse wird der geschriebene Solver praktisch angewendet. Die
 * Repräsentation des "Spielfeldes" findet ebenfalls in dieser Klasse statt
 * 
 * @author Lukas Struppek
 * @version 1.0
 *
 */
public class Application {
	public static void main(String[] args) {

		// Feld wird als 2D-Array abgebildet, da diese eine Interpretation als Matrix
		// erlauben sowie ein strukturiertes Durchlaufen der Elemente in zwei
		// Dimensionan ermöglichen.
		int[][] input = { { 0, 3, 0, 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 1, 9, 5, 0, 0, 0 }, { 0, 0, 8, 0, 0, 0, 0, 6, 0 },

				{ 8, 0, 0, 0, 6, 0, 0, 0, 0 }, { 4, 0, 0, 8, 0, 0, 0, 0, 1 }, { 0, 0, 0, 0, 2, 0, 0, 0, 0 },

				{ 0, 6, 0, 0, 0, 0, 2, 8, 0 }, { 0, 0, 0, 4, 1, 9, 0, 0, 5 }, { 0, 0, 0, 0, 0, 0, 0, 7, 0 } };

		// Zeitmessung des Algorithmus: Startzeit:
		long begin = System.currentTimeMillis();

		// Aufruf der Klassenmethode solve(int[][]) und Übergabe der Referenz auf das
		// Feld als Argument. Methode arbeitet direkt auf der Referenz und ändert daher
		// direkt das Feld im Arbeitsspeicher. Vorher wird geprüft, ob das vorgegebene
		// Feld überhaupt ein gültiges Rätes darstellt.
		if (Solver.validInputField(input) == true)
			Solver.solve(input);

		// Zeitmessung des Algorithmus: Endzeit
		long end = System.currentTimeMillis();

		// Berechnung der benötigten Zeit für die Berechnung
		System.out.println("Benötigte Zeit in Sekunden: " + (end - begin) / 1000.0);

		// Zur Ausgabe der Lösung auf der Konsole wird die Klassenmethode
		// printArray(int[][]) aufgerufen. Auch hier reicht die Übergabe der Referenz,
		// da der Zugriff auf das Objekt im Arbeitsspeicher performanter ist als eine
		// Erzeugung einer Kopie des Feldes.
		Solver.printArray(input);
	}
}