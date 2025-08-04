import java.net.*;
import java.io.*;

class DateTimeClient {
  public static void main(String[] args) {
    String hostName = "";  // Rechner-Name bzw. -Adresse
    int port;              // Port-Nummer
    Socket c = null;       // Socket fuer die Verbindung zum Server

    try {
      hostName = args[0];
      port = Integer.parseInt(args[1]);
      c = new Socket(hostName, port);
      
      BufferedReader vomServer = new BufferedReader(
                                       new InputStreamReader(
                                             c.getInputStream()));
      PrintWriter zumServer = new PrintWriter(
                                    c.getOutputStream(),true);

      BufferedReader vonTastatur = new BufferedReader(
                                         new InputStreamReader(
                                               System.in));

      // Protokoll abwickeln
      System.out.println("Server " + hostName + ":" + port + " sagt:");
      String text = vomServer.readLine(); // vom Server empfangen
      System.out.println(text);           // auf die Konsole schreiben
      text = vonTastatur.readLine();      // von Tastatur lesen
      zumServer.println(text);            // zum Server schicken
      text = vomServer.readLine();        // vom Server empfangen
      System.out.println(text);           // auf die Konsole schreiben
      
      // Socket (und damit auch Stroeme) schliessen
      c.close();         
    } 
    catch (ArrayIndexOutOfBoundsException ae) {
      System.out.println("Aufruf:");
      System.out.println("java DateTimeClient <HostName> <PortNr>");
    } 
    catch (UnknownHostException ue) {
      System.out.println("Kein DNS-Eintrag fuer " + hostName);
    } 
    catch (IOException e) {
      System.out.println("IO-Error");
    }
  }
}
