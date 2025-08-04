import java.awt.*;
public class BlinkThread extends Thread {
  Color farbe;
  Blinklicht lampe;
  public BlinkThread (Blinklicht lampe, Color c) {
    farbe = c;
    this.lampe = lampe;
    lampe.setBackground(farbe);
  }
  public void run() {
    while (true) {
      try {
        sleep(1000);
      } 
      catch (InterruptedException ign) {}
      if (lampe.getBackground() == Color.black)
        lampe.setBackground(farbe);
      else
        lampe.setBackground(Color.black);
    }
  }
}
