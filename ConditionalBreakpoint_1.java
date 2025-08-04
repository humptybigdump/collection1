package edu.kit.aifb.prog1.debugging;
public class ConditionalBreakpoint {
	public static void main(String[] args) {
		double sum = 0.0;
		for(int i = 0; i < 10; i++) {
			double temp = Math.random();
			sum = sum + temp;
		}
		System.out.println(sum);
	}
}