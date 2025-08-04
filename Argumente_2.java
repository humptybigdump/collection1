package vl06;

public class Argumente {
	  public static int summiere(int... werte) {
		   int summe = 0;
		   for (int x : werte)
		    	summe = summe + x;
		   return summe;
	  }
	  public static void main(String[] args) {
		   System.out.println("summiere(1,2): " + summiere(1,2));
		   System.out.println("summiere(1,2,3,4,5): " + summiere(1,2,3,4,5));
	  }
}

