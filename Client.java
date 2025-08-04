import java.util.Date;
import java.rmi.*;
public class Client {
  public static void main(String[] args) {
    try {
      // Objektreferenz des Time-Servers von der Registry besorgen
      RemoteTimeService rts = 
        (RemoteTimeService) Naming.lookup (
                               "rmi://localhost:1099/Zeitansage");
      
      // Zeitansage aufrufen
      Date zeit = rts.getCurrentTime();
      System.out.println("Aktuelle Server-Zeit:");
      System.out.println(zeit);
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}
