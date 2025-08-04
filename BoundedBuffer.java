package edu.kit.tutorial.buffer;

import java.util.ArrayDeque;
import java.util.Deque;

public class BoundedBuffer<E> {
    private final int capacity;
    private final Deque<E> deque;

    public BoundedBuffer(int capacity) {
        this.capacity = capacity;
        this.deque = new ArrayDeque<E>(capacity);
    }

    public synchronized boolean isEmpty() {
        return deque.isEmpty();
    }

    public synchronized boolean isFull() {
        return deque.size() == capacity;
    }

    public synchronized void put(E element) {
        if (isFull()) {
            throw new IllegalStateException("buffer is full!");
        } else {
            deque.addFirst(element);
        }
    }

    public synchronized E get() {
        if (isEmpty()) {
            throw new IllegalStateException("buffer is empty");
        } else {
            return deque.removeLast();
        }
    }
}
