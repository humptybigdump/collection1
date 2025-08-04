package Felder05_Referenzen;

/**
 * 
 * @author Hans Wiwi
 *
 */
public class AenderungAnReferenzvariablen {
	public static void main(String[] args) {
		byte[] a = { 1, 2, 3 };
		byte[] b = { 1, 2, 3 };

		// Hier findet eine Referenzkopie statt
		byte[] c = a;

		// Ausgabe der Werte der einzelnen Felder an der Position 0
		System.out.println("a[0]: " + a[0] + ", b[0]: " + b[0] + ", c[0]: " + c[0]);

		// Änderung eines Wertes über die Referenzvariable c und anschließende
		// Konsolenausgabe
		c[0] = 4;
		System.out.println("a[0]: " + a[0] + ", b[0]: " + b[0] + ", c[0]: " + c[0]);
	}
}
