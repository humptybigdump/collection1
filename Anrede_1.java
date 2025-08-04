package vl06;

public class Anrede {
	public static void main(String[] args) {
		if (args.length >= 2) {
			System.out.println("Hallo, " + args[0] + "!");
			System.out.println("Der Name " + args[1] + " gefaellt mir gut!");
		} else {
			System.out.println("Übergeben Sie bitte mindestens zwei Kommandozeilenargumente!");
		}
		int i = 0;
		for (String p : args) {
			System.out.println("Die " + i + "-te Eingabe lautet: " + p);
			i++;
		}
	}
}
