package Felder02_EindimensionaleFelder;

/**
 * 
 * @author Lukas Struppek
 *
 *         Das Programm zeigt die verschiedenen Möglichkeiten, Felder zu
 *         erzeugen und zu befüllen. Ale erzeugten Felder sind inhaltlich am
 *         Ende des Programms identisch. Es handelt sich jedoch um
 *         unterschiedliche Elemente im Arbeitsspeicher, wie ein
 *         Referenzvergleich zeigen würde.
 */
public class DeklarationUndInitialisierung {

	public static void main(String[] args) {

		// Dynamische Felderzeugung mit separierter Deklaration und Erzeugung
		int[] feld1;
		feld1 = new int[3];
		feld1[0] = 1;
		feld1[1] = 2;
		feld1[2] = 3;

		// Statische Felderzeugung
		int[] feld2 = { 1, 2, 3 };

		// Statische Felderzeugung unter Verwendung von anonymen Arrays
		int[] feld3 = new int[] { 1, 2, 3 };

		// Statische Felderzeugung unter Verwendung von anonymen Arrays mit separierte
		// Deklaration und Erzeugung
		int[] feld4;
		feld4 = new int[] { 1, 2, 3 };
	}

}
