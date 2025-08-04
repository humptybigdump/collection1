import java.awt.*;
import java.awt.event.*;

/** Eigenstaendige Listener-Klasse */
public class ButtonListener implements ActionListener {

  Container c;  // Referenz auf den zu beinflussenden Container

  public ButtonListener (Container c) {
    this.c = c; // Referenz auf den zu beinflussenden Container sichern
  }

  public void actionPerformed(ActionEvent e) {
    // Hintergrundfarbe des Containers zufaellig aendern
    float zufall = (float) Math.random();             
    Color grauton = new Color(zufall,zufall,zufall);
    c.setBackground(grauton);
  }
}
