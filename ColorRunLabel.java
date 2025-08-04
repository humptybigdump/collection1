import java.awt.*;
public class ColorRunLabel extends Label implements Runnable {
  private boolean running = false;
  public ColorRunLabel (Color c) {
    setBackground(c);
    setFont(new Font("Arial",Font.BOLD,50));
    setAlignment(Label.CENTER);
  }
  public void start () {
    running = true;
    new Thread(this).start();
  }
  public void stop () {
    running = false;
  }
  public void run() {
    while (running) {
      setText("" + (int) (10*Math.random()));
      try {
        Thread.sleep(10);
      }
      catch(InterruptedException e) {
        return;
      }
    }
  }
}

