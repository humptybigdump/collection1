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

	public void produce(){
		int element = new Random().nextInt(300);

		//Add (produce) the int element thread-safe at the tail of the queue.
		//If the size of the queue would then exceed the capacity of the queue (int capacity), 
		//the thread has to wait until capacity is free again.

		System.out.println("Produced: " + element);
	}
	
	
	public int consume(){
		int element = -1;

		//Consume (remove) an element thread-safe from the head of the queue.
		//When no element is available for consumption, the thread has to wait until an element is available.
		
		System.out.println("Consumed: " + element);
		return element;
	}
	
	public boolean isRunning() {
		return running; 
	}
	
	public void stopRunning() {
		this.running = false;
	}

}
