class Alpha {
  public synchronized static void a() {
    System.out.println(Thread.currentThread().getName() + " führt a aus");
    Beta.b();
  }
}
class Beta {
  public synchronized  static void b() {
    System.out.println(Thread.currentThread().getName() + " führt b aus");
    Alpha.a();
  }
}
class AThread extends Thread {
  public void run() {
    Alpha.a();
  }
}
class BThread extends Thread {
  public void run() {
    Beta.b();
  }
}
public class Deadlock {
  public static void main (String[] args) {
    new AThread().start();
    new BThread().start();
  }
}
