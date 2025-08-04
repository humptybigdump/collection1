import javax.swing.*;
import java.awt.*;
public class Blinklicht extends JButton {
  public Blinklicht(Color c) {
    new BlinkThread(this, c).start();
  }
}
