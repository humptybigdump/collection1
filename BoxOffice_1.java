package edu.kit.aifb.proksy.goToCinema;

/**
 * Die Klasse BoxOffice repräsentiert die Kasse im Kino
 * 
 * @author ProkSy-Team
 * @version 1.0
 * 
 */
public class BoxOffice {

	private int tickets; // Anzahl der verfügbaren Restkarten

	/**
	 * Konstruktor der Klasse BoxOffice
	 * 
	 */
	public BoxOffice() {
		super();
		tickets = 10; // Legt fest, dass noch 10 Karten verfügbar sind
	}

	/**
	 * Verkaufsprozess einer Eintrittskarte
	 * 
	 */
	synchronized public void sellTicket() {
		try {
			int tempTickets = tickets - 1;
			Thread.sleep(1000);
			tickets = tempTickets;
			System.out.println("Ticket verkauft. Restkarten: " + tickets);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
}
