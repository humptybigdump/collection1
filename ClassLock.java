package synchronizedtest;

public class ClassLock {

    public void test(String name) {
        System.out.println(name + ": Try to take lock..");
        synchronized (ClassLock.class) {
            System.out.println(name + ": .. got it.");
            try {
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            System.out.println(name + ": Releasing lock.");
        }
    }

    /*public static void main(String[] args) {
        ClassLock test = new ClassLock();

        new Thread(() -> test.test("A")).start();
        new Thread(() -> test.test("B")).start();
    }*/

    public static void main(String[] args) {
        ClassLock test = new ClassLock();
        ClassLock test1 = new ClassLock();

        new Thread(() -> test.test("A")).start();
        new Thread(() -> test1.test("B")).start();
    }
}