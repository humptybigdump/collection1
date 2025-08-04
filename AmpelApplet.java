import java.applet.Applet;
import java.awt.*;
public class AmpelApplet extends Applet {
  ColorButton rot, gelb, gruen;
  public void init() {
    setLayout(new GridLayout(3,1));
    rot = new ColorButton(Color.red);
    gelb = new ColorButton(Color.yellow);
    gruen = new ColorButton(Color.green);
    add(rot);
    add(gelb);
    add(gruen);
  }
}
