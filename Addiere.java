public class Addiere {
  public static void main (String[] summand) {
    int i = 0;
    double ergebnis = 0;
    try {
      for (i=0; i < summand.length; i++) 
        ergebnis = ergebnis + Double.parseDouble(summand[i]);
      System.out.println ("Ergebnis: " + ergebnis);
    }
    catch (NumberFormatException nfe) {
      System.out.println ("Unzulaessiger " + (i+1) + ". Summand!");
    }
  }
}
