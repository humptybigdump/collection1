package edu.kit.aifb.proksy.doublylinkedlist;

import edu.kit.aifb.proksy.doublylinkedlist.DoublyLinkedList.ListElement;

/**
 * Implementiert eine doppelt verkettete Liste
 * 
 * @version 1.0
 * @author ProkSy-Team
 */

public class DoublyLinkedList {

	/**
	 * Innere Klasse Repräsentiert ein Listenelement der Liste
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
		// Diese Methode soll ein neues Element am Anfang einfügen
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
		// Diese Methode soll ein neues Element nach dem übergebenen Element pred
		// hinzufügen
		// Falls pred eine null-Referenz ist, soll das neue Element an den Anfang der
		// Liste gesetzt werden
	}

	/**
	 * Löscht das übergebene ListElement aus der Liste
	 * 
	 * @param element ListElement, das gelöscht werden soll
	 */
	public void delete(ListElement element) {
		// Diese Methode soll das ListElement element löschen
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
		// Diese Methode soll die Liste RÜCKWÄRTS als String zurückgeben
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
