class TVProgThread extends Thread {
  public TVProgThread(String str) { //erzeugt Thread namens str
    super(str);
  } 
  public void run() {	
    for (int i = 0; i < 5; i++) {
      System.out.println(i + " " + getName());
      try {
        sleep((int)(Math.random() * 1000));
      } 
      catch (InterruptedException e) {
      } 
    } 
    System.out.println("Fertig! " + getName()); 
  }
}

public class DemoTVProgThread {
  public static void main (String[] args) {
    new TVProgThread("Sendung mit der Maus").start(); 
    new TVProgThread("Akte X").start(); 
    new TVProgThread("Komoedienstadel").start(); 
  }
}

