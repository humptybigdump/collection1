package edu.kit.tutorial.counter;

public class Counter {
    private int value = 0;

    public void increase() {
        synchronized (this) {
            this.value++;
        }
    }

    public synchronized int getValue() {
        return value;
    }
}
