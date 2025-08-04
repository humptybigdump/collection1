import java.applet.Applet;
import java.awt.*;
import javax.swing.*;
public class BlinklichtApplet extends JApplet {
  public void init() {
    Container c = getContentPane();
    c.setLayout(new BorderLayout());
    Blinklicht bl = new Blinklicht(Color.red);
    c.add(bl);
  }
}

