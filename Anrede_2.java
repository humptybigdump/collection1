package vl06;

public class Anrede {
	  public static void main(String[] args){
	      System.out.println("Hallo, " + args[0] + "!");
	      System.out.println("Der Name " + args[1] + " gefaellt mir gut!");
	      int i=0;
	      for (String p : args){
	          System.out.println("Die " + i + "-te Eingabe lautet: " + p);
	          i++;
	      }
   }
}

