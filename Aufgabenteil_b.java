import java.util.stream.Stream;

/**
 * @author ProkSy-Team
 * @version 1.0
 *
 */
public class Aufgabenteil_b {

	public static void main(String[] args) {
		// Berechnung der Folge von Zweierpotenzen und Limitierung auf 10 Zahlen
		Stream.iterate(2, i -> i * 2).limit(10).forEach(System.out::println);
	}

}
