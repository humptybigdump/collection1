class Blah {
  public static void a() {
    b();
  }
  public static void b() {
    throw new ArithmeticException("Fehler!");
  }
  public static void main(String args[]){
    try {
      a();
      System.out.println ("OK!");
    }  
    catch (ArithmeticException e) {
      System.out.println (e.getMessage());
    }
  }
}

