public class AutoBoxingDangers {
  public static void main(String[] args) {
     Double u = 1.0, v = 1.0;
     System.out.println(u==v);     // ? false
     Integer i = 126, j = 126;
     System.out.println(i==j);     // ? true
     i++; j++;
     System.out.println(i==j);     // ? true
     i++; j++;     
     System.out.println(i==j);     // ? false 
     i = 1111; j = 1111; 
     System.out.println(i==j);     // ? false   
  }
}

/*

Java Language Specification:

  If the value p being boxed is true, false, a byte, a char in the range 
  \u0000 to \u007f, or an int or short number between -128 and 127, then 
  let r1 and r2 be the results of any two boxing conversions of p. It is 
  always the case that r1 == r2.

*/
