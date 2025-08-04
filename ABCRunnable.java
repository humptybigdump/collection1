class ABCRunnable implements Runnable {
  public void run() {
    for (int i = 65; i < 91; i++) {
      System.out.println(Thread.currentThread().getName() + 
                         ": " + (char)i);
      try {
        Thread.sleep(1000); // pausiere eine Sekunde
      } 
      catch (InterruptedException e) {
        System.out.println(e);
      }
    }
  }
  public static void main(String[] args) {
    Runnable z1 = new ABCRunnable(), z2 = new ABCRunnable();
    Thread t1 = new Thread(z1), t2 = new Thread(z2);
    t1.start(); 
    t2.start();
  }
}

