import java.util.*;
public class Assertions {
  public static Scanner in = new Scanner(System.in); 
  public static double kehrwert (double x) {
    assert x != 0 : "/ by 0";
    return 1/x;
  }
  public static void main (String[] summand) {
    System.out.print("x = ");
    double x = in.nextDouble();
    try {
      System.out.println(kehrwert(x));
    }
    catch (AssertionError e) {
      System.out.println (e.getMessage());
    }
  }
}
