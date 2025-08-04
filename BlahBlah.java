class BlahBlah {
  public static void a() {
    b();
  }
  public static void b() {
    throw new Exception("Peng!");
  }
  public static void main(String[] args){
    try {
      a();
      System.out.println ("OK!");
    }  
    catch (Exception e) {
      System.out.println (e.getMessage());
    }
  }
}

