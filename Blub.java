class Blub {
  public static void a(int i) {
    System.out.println(1/i);
    b(i-1);
  }
  public static void b(int i) {
    System.out.println(1/i);
    c(i-1);
  }
  public static void c(int i) {
    System.out.println(1/i);
  }
  public static void main(String args[]){
    try {
      a(2);
    }  
    catch (ArithmeticException e) {
      System.out.println (e.getMessage());
      System.out.println (e);
      e.printStackTrace();
    }
  }
}

