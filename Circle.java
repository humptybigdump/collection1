  class Circle extends Kreis implements Sleeper {
    Circle (int r, int x, int y) {
      super(r,x,y);
    }
    public void wakeUp() {
      for (long i=1; i<=ONE_SECOND; i++)
        System.out.println("Chhrrrzzzzz..."); 
      System.out.println("Jetzt bin ich wach!"); 
      show();
    }
  } 

