package Felder05_Referenzen;

import java.util.Scanner;

/**
 * 
 * @author Lukas Struppek
 *
 */

public class Dreieck {

	public static void main(String[] args) {
		// Abfrage der Größe des zu berechnenden Dreiecks
		Scanner scanner = new Scanner(System.in);
		System.out.println("Größe des Pascalschen Dreiecks: ");
		int groesse = scanner.nextInt();

		// Erzeugung des Feldes mit erster Dimension entsprechend der Eingabe. Da es
		// sich nicht um ein rechteckiges Feld handelt, muss die zweite Dimension
		// jeweils separat erzeugt werden. Die ersten beiden Dimensionen werden an
		// dieser Stelle manuell erzeugt, um dem Algorithmus Startwerte zu geben.
		int[][] dreieck = new int[groesse][];
		dreieck[0] = new int[] { 1 };
		dreieck[1] = new int[] { 1, 1 };

		// Für jede zusätzliche Ebene wird zunächst ein eindimensionales Feld mit
		// entsprechender Größe bestimmt. Die Größe kann leicht berechnet werden.
		// Anzumerken ist, dass der Algorithmus erst in der dritten Zeile beginnt. Da
		// die erste und die letzte Ziffe jeweils eine 1 ist, werden diese bereits
		// festgelegt.
		for (int i = 2; i < dreieck.length; i++) {
			dreieck[i] = new int[i + 1];
			dreieck[i][0] = 1;
			dreieck[i][dreieck[i].length - 1] = 1;

			// Die Werte im inneren jeder Zeile werden nun berechnet aus der Summe der Zahl
			// in der Spalte darüber und der Zahl in der Spalte darüber um eine Position
			// nach links versetzt. Die Schleife beginnt in jeder Zeile bei der zweiten Zahl
			// und endet bei der Vorletzten.
			for (int j = 1; j < dreieck[i].length - 1; j++) {
				dreieck[i][j] = dreieck[i - 1][j - 1] + dreieck[i - 1][j];
			}
		}

		// Im folgenden wird das Dreieck zeilenweise durch Verwendung von zwei
		// verkürzten und verschachtelten for-Schleifen ausgegeben.
		for (int[] f : dreieck) {
			for (int e : f)
				System.out.print(e + " ");
			System.out.println();
		}
	}

}
