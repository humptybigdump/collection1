import java.applet.Applet;
import java.awt.*;
import java.awt.event.*;
public class AutomatApplet extends Applet {
  ColorRunLabel rotAnzeige, gelbAnzeige, gruenAnzeige;
  StartStopButton rotKnopf, gelbKnopf, gruenKnopf;
  public void init() {
    rotAnzeige = new ColorRunLabel(Color.red);
    gelbAnzeige = new ColorRunLabel(Color.yellow);
    gruenAnzeige = new ColorRunLabel(Color.green);
    rotKnopf = new StartStopButton(Color.red);
    gelbKnopf = new StartStopButton(Color.yellow);
    gruenKnopf = new StartStopButton(Color.green);
    setLayout(new GridLayout(2,3,5,5));
    add(rotAnzeige);
    add(gelbAnzeige);
    add(gruenAnzeige);
    add(rotKnopf);
    add(gelbKnopf);
    add(gruenKnopf);
    rotKnopf.addActionListener(new KnopfListener(rotAnzeige, rotKnopf));
    gruenKnopf.addActionListener(new KnopfListener(gruenAnzeige, gruenKnopf));
    gelbKnopf.addActionListener(new KnopfListener(gelbAnzeige, gelbKnopf));
  }

  class KnopfListener implements ActionListener {
    ColorRunLabel crl;
    StartStopButton ssb;
    KnopfListener (ColorRunLabel crl, StartStopButton ssb) {
      this.crl = crl;
      this.ssb = ssb;
    }
    public void actionPerformed (ActionEvent e) {
      if (ssb.isStart())
        crl.start();
      else
        crl.stop();
      ssb.switchText();
    }
  } 
  
}
