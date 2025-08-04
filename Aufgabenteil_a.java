import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author ProkSy-Team
 * @version 1.0
 *
 */
public class Aufgabenteil_a {

	public static void main(String[] args) {
		// Aufsplittung in zwei Zeilen zur besseren Lesbarkeit
		Stream<Integer> stream = Stream.generate(() ->(int) (Math.random() * 201) - 100);
		
		// Begrenzung des Unendlichen Streams auf 50 Elemente
		// Erzeugung einer Liste aus den Elementen des Streams
		List<Integer> liste = stream.limit(50).collect(Collectors.toList());
		System.out.println(liste);
	}

}
