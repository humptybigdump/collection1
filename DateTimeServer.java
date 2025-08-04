import java.io.*;
import java.net.*;
class DateTimeServer {
  public static void main(String[] args) {
    try {
      int port = Integer.parseInt(args[0]);           // Port-Nummer
      ServerSocket server = new ServerSocket(port);   // Server-Socket
      System.out.println("DateTimeServer laeuft");    // Statusmeldung
      Socket s = server.accept();     // Client-Verbindung akzeptieren
      new DateTimeProtokoll(s).transact();      // Protokoll abwickeln
    }
    catch (ArrayIndexOutOfBoundsException ae) {
      System.out.println("Aufruf: java DateTimeServer <Port-Nummer>");
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
