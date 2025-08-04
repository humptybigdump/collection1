package edu.kit.aifb.proksy.doublylinkedlist;

import java.util.*;

/**
 * Demonstriert eine Liste der Klasse DoublyLinkedList
 *
 * @version 1.0
 * @author ProkSy-Team
 */
public class DoublyLinkedListDemo {
	private static DoublyLinkedList liste;
	private static boolean running;
	private static String entry;

	/**
	 * Main-Methode der Klasse DoubyLinkedListDemo
	 * 
	 * @param args Kommandozeilenparamenter
	 */
	public static void main(String[] args) {
		Scanner scan = new Scanner(System.in);

		running = true;
		liste = new DoublyLinkedList();
		System.out.println("Neue int-Liste erstellt.");

		while (running) {
			System.out.println(
					"Was wollen Sie tun? (a)dd - (d)elete - (i)nsert - (f)orward print - (r)everse print - (c)lose? ");
			entry = scan.next();

			switch (entry) {
			case "a":
				System.out.println("Welcher Wert soll hinzugefuegt werden? ");
				liste.add(scan.nextInt());
				System.out.println("Listenausgabe: " + liste);
				break;
			case "d":
				liste.delete(liste.getHeadElement()); // Lösche erstes Element
				System.out.println("Listenausgabe: " + liste);
				break;
			case "i":
				System.out.println("Nach welcher Position soll ein Wert hinzugefuegt werden? ");
				int pos = scan.nextInt();
				DoublyLinkedList.ListElement pred = liste.getElementAtPosition(pos);
				System.out.println("Welcher Wert soll hinzugefuegt werden? ");
				liste.insert(scan.nextInt(), pred);
				System.out.println("Listenausgabe: " + liste);
				break;
			case "f":
				System.out.println("Listenausgabe: " + liste);
				break;
			case "r":
				System.out.println("Listenausgabe: " + liste.toReverseString());
				break;
			case "c":
				running = false;
				break;
			default:
				System.out.println("Bitte nur gueltige Werte angeben.");
			}
		}
		scan.close();
	}
}
