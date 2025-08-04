import java.net.*;
import java.io.*;
import java.util.*;
class DateObjectClient {
  public static void main(String[] args) {
    try {
      BufferedReader ein = new BufferedReader(   // fuer Tastatureingaben
                                 new InputStreamReader(System.in));
      Socket c = new Socket("localhost", 4711);
      ObjectInputStream vomServer = new ObjectInputStream(
                                         c.getInputStream());
      DataOutputStream zumServer = new DataOutputStream(
                                         c.getOutputStream());

      System.out.println("Abrufen von Date-Objekten beim DateObjectServer");

      while (true) {
        System.out.println("Geben Sie");
        System.out.println("  1 fuer einen neuen Date-Objekt-Abruf oder");
        System.out.println("  0 fuer Programm-Abbruch ein.");
        System.out.print("Ihre Wahl? ");
        int wahl = Integer.parseInt(ein.readLine());    // Tastatureingabe
        if (wahl == 0) {
          zumServer.writeInt(wahl);                // 0 an Server schicken
          break;
        }
        if (wahl == 1) {
          zumServer.writeInt(wahl);                // 1 an Server schicken
          Date d = (Date) vomServer.readObject(); // Date-Objekt empfangen
          System.out.println("Empfangenes Date-Object: ");
          System.out.println();
          System.out.println(d);  // Bildschirmausgabe (mittels toString())
          System.out.println();
        }
      }
      System.out.println("Date-Objekt-Abruf-Programm beendet");
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
