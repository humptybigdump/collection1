class BlahBlahBlah {
  public static void a() throws Exception {
    b();
  }
  public static void b() throws Exception {
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
