package producerconsumer;

import java.util.Random;
import java.util.concurrent.ConcurrentLinkedQueue;

public class Buffer {

	private ConcurrentLinkedQueue<Integer> queue;
	private final int capacity = 2;
	private volatile boolean running = true;

	public Buffer() {
		queue = new ConcurrentLinkedQueue<Integer>();
	}

	public void produce() {
		int element = new Random().nextInt(300);
		synchronized (this) {
			while (queue.size() >= capacity) {
				try {
					wait();
				} catch (InterruptedException e) {
					// Set interrupt flag to make success distinguishable from interrupt for caller
					Thread.currentThread().interrupt();
					// Return to enable ending the execution
					return;
				}
			}

			queue.add(element);
			notifyAll();
		}
		System.out.println("Produced: " + element);
		try {
			Thread.sleep(500);
		} catch (InterruptedException e) {
			// Set interrupt flag to make success distinguishable from interrupt for caller
			Thread.currentThread().interrupt();
			return;
		}
	}

	public int consume() {
		int element = -1;
		synchronized (this) {
			while (queue.size() == 0) {
				try {
					wait();
				} catch (InterruptedException e) {
					// Set interrupt flag to make success distinguishable from interrupt for caller
					Thread.currentThread().interrupt();
					return -1;
				}
			}
			element = queue.poll();
			notifyAll();
		}
		System.out.println("Consumed: " + element);
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// Set interrupt flag to make success distinguishable from interrupt for caller
			Thread.currentThread().interrupt();
			return element;
		}

		return element;
	}

	public synchronized boolean isRunning() {
		return running;
	}

	public synchronized void stopRunning() {
		this.running = false;
	}
}
