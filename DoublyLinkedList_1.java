package edu.kit.aifb.proksy.doublylinkedlist;

/**
 * Implementiert eine doppelt verkettete Liste
 * 
 * Lösungsvorschlag
 * 
 * @version 1.0
 * @author ProkSy-Team
 */

public class DoublyLinkedList {

	/**
	 * Innere Klasse repräsentiert ein Listenelement der Liste
	 * 
	 * @author ProkSy-Team
	 * 
	 */
	static class ListElement {
		private Object element;
		private ListElement next;
		private ListElement previous;

		/**
		 * Konstruktor für ein ListElement, das eine Referenz auf das übergebene Objekt
		 * enthält
		 * 
		 * @param o Objekt, auf das das ListElement referenzieren soll
		 */
		public ListElement(Object o) {
			element = o;
			next = null;
			previous = null;
		}
	}

	private ListElement head;
	private ListElement tail;

	/**
	 * Konstruktor für eine leere doppelt verkettete Liste
	 */
	public DoublyLinkedList() {
		head = null;
		tail = null;
	}

	/**
	 * Konstruktor für eine doppelt verkettete Liste, die das übergebene Objekt
	 * enthält
	 * 
	 * @param o Objekt, das in die Liste aufgenommen werden soll
	 */
	public DoublyLinkedList(Object o) {
		head = new ListElement(o);
		tail = head;
	}

	/**
	 * Fügt ein Objekt am Anfang der Liste ein.
	 * 
	 * @param o Objekt, das eingefügt werden soll
	 * @return Liefert das ListElement zurück, das die Referenz auf das eingefügte
	 *         Objekt enthält
	 */
	public ListElement add(Object o) {
		ListElement newElement = new ListElement(o);

		if (head == null && tail == null) {
			head = newElement;
			tail = head;
		} else {
			newElement.next = head;
			head.previous = newElement;
			head = newElement;
		}

		return newElement;
	}

	/**
	 * Fügt ein Objekt nach dem übergebenen ListElement ein.
	 * 
	 * @param o    Objekt, das eingefügt werden soll
	 * @param pred ListElement, nach dem das Objekt eingefügt werden soll
	 * @return Liefert das ListElement zurück, das die Referenz auf das eingefügte
	 *         Objekt enthält
	 */
	public ListElement insert(Object o, ListElement pred) {
		ListElement newElement = new ListElement(o);

		if (pred == null) { // Am Anfang einfügen
			add(o);
		} else if (pred.next == null) { // Am Ende einfügen
			tail = newElement;
			newElement.previous = pred;
			pred.next = newElement;
		} else { // nach pred einfügen
			newElement.next = pred.next;
			newElement.previous = pred;
			pred.next.previous = newElement;
			pred.next = newElement;
		}

		return newElement;
	}

	/**
	 * Löscht das übergebene ListElement aus der Liste
	 * 
	 * @param element ListElement, das gelöscht werden soll
	 */
	public void delete(ListElement element) {
		if (element == head && element != tail) { // Element ist erstes Element
			head = head.next;
			head.previous = null;
		} else if (element != head && element == tail) { // Element ist letztes
															// Element
			tail = tail.previous;
			tail.next = null;
		} else if (element == head && element == tail) { // Element ist einziges
															// Element
			head = null;
			tail = null;
		} else if (element != head && element != tail) { // Element ist nicht
															// erstes und nicht
															// letztes Element
			element.previous.next = element.next;
			element.next.previous = element.previous;
		}
	}

	/**
	 * Gibt die Liste in ursprünglicher Reihenfolge aus
	 * 
	 * @return String des Listeninhalts in ursprünglicher Reihenfolge
	 */
	public String toString() {
		String s = "(";
		ListElement help = head;

		while (help != null && help.next != null) {
			s = s + help.element + ", ";
			help = help.next;
		}

		if (help != null) {
			s = s + help.element;
		}

		return s + ")";
	}

	/**
	 * Gibt die Liste in umgekehrter Reihenfolge aus
	 * 
	 * @return String des Listeninhalts in umgekehrter Reihenfolge
	 */
	public String toReverseString() {
		String s = "(";
		ListElement help = tail;

		while (help != null && help.previous != null) {
			s = s + help.element + ", ";
			help = help.previous;
		}

		if (help != null) {
			s = s + help.element;
		}

		return s + ")";
	}

	public ListElement getHeadElement() {
		return head;
	}

	public ListElement getTailElement() {
		return tail;
	}
	
	/**
	 * Gibt das ListElement an einer bestimmten Position in der Liste zurück.
	 * 
	 * @param position Die Position in der Liste
	 * @return ListElement an der Position
	 */
	public ListElement getElementAtPosition(int position) {
		if (head == null) {
			return null;
		}
		ListElement e = head;

		for (int i = 0; i < position; i++) {
			if (e.next == null) {
				return e;
			}
			e = e.next;
		}
		return e;
	}
}
