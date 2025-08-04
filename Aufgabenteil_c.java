import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author ProkSy-Team
 * @version 1.0
 */
public class Aufgabenteil_c {
	public static void main(String[] args) {
		/*
		 * Erstes Argument in iterate gibt die Ausgangszahl an. Anschließend wird
		 * basierend auf dem vorherigen Element jeweils ein neuer Wert berechnet
		 */
		List<Double> liste = Stream
				.iterate(43.46, s -> Math.round(100 * (s + 0.17 + 2 * new Random().nextGaussian())) / 100.0).limit(100)
				.collect(Collectors.toList());

		// Zeilenweise Ausgabe der Ergebnisse
		liste.forEach(System.out::println);

		// Simpler Plot des Aktienkurses
		new Plot(liste);
	}
}
