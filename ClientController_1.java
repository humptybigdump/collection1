package edu.kit.aifb.proksy.Erdkunde.client.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

import edu.kit.aifb.proksy.Erdkunde.server.model.*;

/**
 * Diese Klasse repräsentiert den Client Controller, der den Kontakt zum Server
 * herstellt.
 * 
 * @author ProkSy-Team
 * @version 1.0
 */
public class ClientController {
	private ViewController controller;
	private static boolean bundesland;

	private static final String HOST = "localhost";
	private static final int PORT = 7777;

	private Socket socket;

	private PrintWriter zumServer;
	private BufferedReader vomServer;
	private String response;

	/**
	 * Methode, mit der der ClientController eine Instanz des ViewControllers
	 * zugeordnet bekommt.
	 * 
	 * @param controller
	 */
	public void setViewController(ViewController controller) {
		this.controller = controller;
	}

	/**
	 * Diese Methode stellt den Kontakt zum Server her und öffnet die Streams.
	 * 
	 * @param bundesland
	 */
	public void connectToServer(boolean bundesland) {
		try {
			this.bundesland = bundesland;
			socket = new Socket(HOST, PORT);
			zumServer = new PrintWriter(socket.getOutputStream(), true);
			vomServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		} catch (UnknownHostException e) {
			System.err.println("Don't know host: " + HOST);
			System.exit(1);
		} catch (IOException e) {
			System.err.println("Couldn't get I/O for connection  to: " + HOST);
			System.exit(1);
		}
	}

	/**
	 * Die Methode sendet die Eingabe des Nutzers an den Server.
	 * 
	 * @param message
	 * @param bundesland
	 */
	public void sendMessage(String message, boolean bundesland) {
		try {
			this.bundesland = bundesland;
			String nachricht;
			if (bundesland) {
				nachricht = "Bundesland\n" + message;
			} else {
				nachricht = "Hauptstadt\n" + message;
			}
			zumServer.println(nachricht);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Die Methode empfängt die Antwort des Servers und gibt sie als Ausgabe weiter.
	 * 
	 * @return response
	 */
	public String receiveMessage() {
		try {
			response = vomServer.readLine();
			return response;
		} catch (IOException e) {
			e.printStackTrace();
			return "Es ist ein Fehler aufgetreten";

		}

	}
}
