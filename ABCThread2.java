class ABCThread2 extends Thread {
  public void run() {
    for (int i = 65; i < 91; i++) {
      System.out.println(getName() + ": " + (char)i);
      try {
        sleep(1000);
      } 
      catch (InterruptedException e) {
        System.out.println(e);
      }
    }
  }
  public static void main(String[] args) {
    Thread t1 = new ABCThread(), t2 = new ABCThread();
    t1.setDaemon(true);
    t2.setDaemon(true);
    t1.start(); 
    t2.start();
  }
}
