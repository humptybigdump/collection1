import java.awt.*;
public class ColorChanger extends Thread {
  Button lampe; // Referenz auf das Lampenobjekt
  Color farbe;  // Referenz auf das Farbenobjekt der Lampe
  int time1, time2; // Schaltzeiten der Lampe
  public ColorChanger (Color farbe, Button lampe) {
    this.farbe = farbe;
    this.lampe = lampe;
    if (farbe == Color.green) {         // brennt zu Beginn
      lampe.setBackground(Color.green); // wechselt nach jew.
      time1 = 1000;  time2 = 3000;      // 1 und 3 Sekunden
    }
    else {
      lampe.setBackground(Color.black); // brennt zu Beginn nicht
      if (farbe == Color.yellow) {      // wechselt nach jew.
        time1 = 1000;  time2 = 1000;    // 1 Sekunde
      }
      else {
        time1 = 2000;  time2 = 2000;    // 2 Sekunden
      }
    }
  }
  public void run() {
    while (true) {
      try {
        sleep(time1);
      } 
      catch (InterruptedException ign) { 
      }
      farbenTausch();
      try {
        sleep(time2);
      } 
      catch (InterruptedException ign) { 
      }
      farbenTausch();
    }
  }
  public void farbenTausch() {
    if (lampe.getBackground() == Color.black)
      lampe.setBackground(farbe);
    else
      lampe.setBackground(Color.black);
  }
}

