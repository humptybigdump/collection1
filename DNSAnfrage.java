import java.io.*;
import java.net.*;
class DNSAnfrage {
 public static void main(String[] args) {
   if (args.length != 1) 
     System.out.println("Aufruf: java DNSAnfrage <hostname>");
   else 
     try {
       InetAddress ip = InetAddress.getByName(args[0]);
       System.out.println("IP-Adresse von " + args[0] + ":\n" + ip);
     } catch (UnknownHostException ex) {
       System.out.println(args[0] + " ist dem DNS nicht bekannt.");
     }
  }
}

