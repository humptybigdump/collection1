public class AutoBoxingDemo {
  public static void main(String[] args) {
    Object[] w = new Object[2];
    Integer a = 3;
    Double b = 5.0;
    w[0] = 7;
    w[1] = 9.0;
    double x = 7 + 4 * a - b / 8;
    System.out.println(x);
    System.out.println(w[0].getClass());
    System.out.println(w[1].getClass());
  }
}
