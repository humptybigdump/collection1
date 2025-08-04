package racecondition;

public class Counter implements Runnable {

    private final int times;

    private Integer counter;

    public Counter(int times) {
        this.times = times;

        this.counter = 0;
    }

    @Override
    public void run() {
        for (int i = 0; i < times; i++) {
            synchronized (this) {
                counter++;
            }
        }
    }

    public Integer getResult() {
        return counter;
    }
}