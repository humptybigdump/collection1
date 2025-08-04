import java.io.*;
class Create {
  public static void main(String[] args) {
    try {
      File f = new File(args[0]);                       // Verzeichnis
      File g = new File(args[0] + "/" + args[1]);             // Datei
      File h = new File(args[0] + "/" + args[1] + ".txt");    // Datei
      if (f.exists()) {
        System.out.println("Verzeichnis oder Datei " + args[0] +
                           " existiert bereits");
        return;
      }
      f.mkdir();            // Verzeichnis anlegen
      g.createNewFile();    // Datei anlegen
      h.createNewFile();    // Datei anlegen
      String[] dateien = f.list();  // Verzeichniseintraege aufzaehlen
      System.out.println("Dateien im Verzeichnis " + args[0] + ":");
      for (int i=0; i<dateien.length; i++)
        System.out.println(dateien[i]);
    }
    catch(ArrayIndexOutOfBoundsException ae) {
      System.out.println("Aufruf:  java Create <Verzeichnis> <Datei>");
    }
    catch(Exception e) {
      System.out.println(e);
    }
  }
}

