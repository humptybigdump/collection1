import java.io.*;
import java.net.*;
class DateObjectServer {
  public static void main(String[] args) {
    try {
      ServerSocket server = new ServerSocket(4711);   // Server-Socket
      System.out.println("DateObectServer laeuft");   // Statusmeldung
      while(true) {
        Socket s = server.accept();   // Client-Verbindung akzeptieren
        new DateObjectDienst(s).start();        // Protokoll abwickeln
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}
