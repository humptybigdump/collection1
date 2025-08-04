import javax.swing.*;
import java.net.*;
import java.io.*;
import java.applet.*;
public class DateTimeApplet extends JApplet {
  public void init() {
    try {
      Socket socket = new Socket(this.getCodeBase().getHost(), 7777);
      BufferedReader in = new BufferedReader(
                                new InputStreamReader(
                                      socket.getInputStream()));
      PrintWriter out = new PrintWriter(
                              socket.getOutputStream(), true);
      in.readLine();
      out.println("date");
      String s = in.readLine();
      getContentPane().add(new JLabel(s,JLabel.CENTER));
    }
    catch (IOException e) {
      String s = "Verbindung zum DateTimeServer fehlgeschlagen!";
      getContentPane().add(new JLabel(s,JLabel.CENTER));
    }
  }
}
