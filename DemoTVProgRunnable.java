class TVProgRunnable implements Runnable {
  Thread t;
  TVProgRunnable(String str) { //erzeugt Thread, der mit diesem 
    t = new Thread (this,str); //Objekt verbunden ist
  } 
  public void start() { // da t mit einem Objekt verbunden ist,
    t.start();          // wird dir run-Methode des Objekts
  }                     // ausgeführt 
  public void run() {	
    for (int i = 0; i < 5; i++) {
      System.out.println(i + " " + t.getName());
      try {
        t.sleep((int)(Math.random() * 1000));
      } 
      catch (InterruptedException e) {
      } 
    } 
    System.out.println("Fertig! " + t.getName()); 
  }
}

public class DemoTVProgRunnable {
  public static void main (String[] args) {
    new TVProgRunnable("Sendung mit der Maus").start(); 
    new TVProgRunnable("Akte X").start(); 
    new TVProgRunnable("Komoedienstadel").start(); 
  }
}
