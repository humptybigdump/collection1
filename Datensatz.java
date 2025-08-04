import java.io.*;
public class Datensatz implements Serializable {
  public int    nr;   // Nummer des Datensatzes
  public double wert; // Wert des Datensatzes
  public String kom;  // Kommentar 

  public Datensatz (int nr, double wert, String kom) { // Konstruktor
    this.nr = nr;
    this.wert = wert;
    this.kom = kom;
  }

  public String toString() {    // Erzeugung einer String-Darstellung
    return "Nr. " + nr + ": " + wert + " (" + kom + ")";
  }
}
