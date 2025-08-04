package task1;

public class Casting {
    public static void main(String[] args) {
        int value1 = 5;
        double value2 = 3.5;

        int value3 = (int) value2;
        int result = value1 + value3;

        System.out.println(result);
    }
}