import java.io.*;
public class DataWriteAndRead {
  // Speichert elementare Werte in einer Datei und liest sie wieder ein
  public static void main(String[] args) {
    try {
      File datei = new File("binaer.dat");
      FileOutputStream out = new FileOutputStream(datei);
      DataOutputStream dout = new DataOutputStream(out);
      dout.writeInt(1);
      dout.writeDouble(2.3);
      dout.writeChar('a');
      dout.writeBoolean(true);
      dout.close();
      FileInputStream in = new FileInputStream(datei);
      DataInputStream din = new DataInputStream(in);
      System.out.println("int:     " + din.readInt());
      System.out.println("double:  " + din.readDouble());
      System.out.println("char:    " + din.readChar());
      System.out.println("boolean: " + din.readBoolean());
    }
    catch(IOException e) {
      System.out.println(e);
    }
  }
}
