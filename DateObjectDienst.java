import java.io.*;
import java.net.*;
import java.util.*;
import java.text.*;
class DateObjectDienst extends Thread {
  Socket s;                     // Socket in Verbindung mit dem Client
  DataInputStream vomClient;    // Eingabe-Strom vom Client
  ObjectOutputStream zumClient; // Ausgabe-Strom zum Client
  
  public DateObjectDienst (Socket s) {  // Konstruktor
    try {
      this.s = s;
      vomClient = new DataInputStream(s.getInputStream());
      zumClient = new ObjectOutputStream(s.getOutputStream());
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
  
  public void run() {  // Methode, die das Protokoll abwickelt
    System.out.println("DataObjectProtokoll gestartet");
    try {
      while (true) {
        int wunsch = vomClient.readInt();       // vom Client empfangen
        if (wunsch == 0)
          break;                                // Schleife abbrechen
        Date jetzt = new Date();                // Date-Objekt erzeugen
        zumClient.writeObject(jetzt);           // Objekt an Client schicken
      }
      s.close();          // Socket (und damit auch Stroeme) schliessen
    }
    catch (IOException e) {
      e.printStackTrace();
    }
    System.out.println("DataObjectProtokoll beendet");
  }
}
