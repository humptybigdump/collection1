/*
 * This class requires no changes from the 1.0 version. 
 * It's kept here so the rest of the example can compile.
 */

public class Chopstick {
    Thread holder = null;

    public synchronized void grab() throws InterruptedException {
        while (holder != null)
            wait();
        holder = Thread.currentThread();
    }

    public synchronized void release() {
        holder = null;
        notify();
    }

    public synchronized void releaseIfMine() {
        if (holder == Thread.currentThread())
            holder = null;
        notify();
    }
}
