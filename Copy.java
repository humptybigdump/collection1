import java.io.*;
public class Copy {
  public static void main(String[] args) throws IOException {
    File inputFile = new File("Eingabe.txt");
    File outputFile = new File("Ausgabe.txt");
		FileReader in = new FileReader(inputFile); 
		FileWriter out = new FileWriter(outputFile); 
		int c;
		while ((c = in.read()) != -1) { //  Test auf End-of-File
		  out.write(c);		
		  System.out.print((char)c); // zu einfach, nur für kurze Dateien sinnvoll
		}
		System.out.println(); 
		in.close();	
		out.close(); 
  }
}
