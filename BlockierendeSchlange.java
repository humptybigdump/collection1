import java.util.LinkedList;

public class BlockierendeSchlange<T> {
    private LinkedList<T> schlange = new LinkedList<>();
    private static final int MAX_GROESSE = 128;


    synchronized void legeAb(T t) throws InterruptedException {
        while (schlange.size() >= MAX_GROESSE) { this.wait(); }
        schlange.add(t);
        this.notifyAll();
    }

    synchronized T entnehme() throws InterruptedException {
        while (schlange.isEmpty()) {this.wait(); }
        this.notifyAll();
        return schlange.remove();
    }
}
