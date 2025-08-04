import java.io.*;
import java.net.*;
import java.util.*;
import java.text.*;
class DateTimeDienst extends Thread {
  static SimpleDateFormat     // Formate fuer den Zeitpunkt
    time = new SimpleDateFormat("'Es ist gerade 'H'.'mm' Uhr.'"),
    date = new SimpleDateFormat("'Heute ist 'EEEE', der 'dd.MM.yy");
  static int anzahl = 0;      // Anzahl der Clients insgesamt
  int nr = 0;                 // Nummer des Clients
  Socket s;                   // Socket in Verbindung mit dem Client
  BufferedReader vomClient;   // Eingabe-Strom vom Client
  PrintWriter zumClient;      // Ausgabe-Strom zum Client
  
  public DateTimeDienst (Socket s) {  // Konstruktor
    try {
      this.s = s;
      nr = ++anzahl;
      vomClient = new BufferedReader(
                        new InputStreamReader(
                              s.getInputStream()));
      zumClient = new PrintWriter(
                        s.getOutputStream(),true);
    }
    catch (IOException e) {
      System.out.println("IO-Error bei Client " + nr);
      e.printStackTrace();
    }
  }
  
  public void run() {  // Methode, die das Protokoll abwickelt
    System.out.println("Protokoll fuer Client " + nr + " gestartet");
    try {
      while (true) {
        zumClient.println("Geben Sie DATE, TIME oder QUIT ein");
        String wunsch = vomClient.readLine();   // vom Client empfangen
        if (wunsch == null || wunsch.equalsIgnoreCase("quit"))
          break;                                // Schleife abbrechen
        Date jetzt = new Date();                // Zeitpunkt bestimmen
                          // vom Client empfangenes Kommando ausfuehren
        if (wunsch.equalsIgnoreCase("date"))
          zumClient.println(date.format(jetzt));
        else if (wunsch.equalsIgnoreCase("time"))
          zumClient.println(time.format(jetzt));
        else 
          zumClient.println(wunsch + " ist als Kommando unzulaessig!");
      }
      s.close();          // Socket (und damit auch Stroeme) schliessen
    }
    catch (IOException e) {
      System.out.println("IO-Error bei Client " + nr);
    }
    System.out.println("Protokoll fuer Client " + nr + " beendet");
  }
}
