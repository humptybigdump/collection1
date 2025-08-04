package Felder04_MehrdimensionaleFelder;

/**
 * 
 * @author Lukas Struppek
 *
 */
public class DreieckigesFeld {
	public static void main(String[] args) {
		// Statische Erzeugung eines dreieckigen Feldes
		int[][] dreieck = { { 1 }, { 2, 3 }, { 4, 5, 6 }, { 7, 8, 9, 10 } };

		// Dynamische Erzeugung eines identischen Feldes. Dabei werden zwei
		// verschachtelte for-Schleifen verwendet, um zum einen über die Dimensionen zu
		// iterieren als auch in den jeweils erzeugten Feldern in der zweiten Dimension.
		int[][] dreieck2 = new int[4][];
		int zaehler = 1;
		for (int i = 0; i < dreieck2.length; i++) {
			dreieck2[i] = new int[i + 1];
			for (int j = 0; j < dreieck2[i].length; j++)
				dreieck2[i][j] = zaehler++;
		}
	}
}
