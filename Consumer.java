package producerconsumer;

public class Consumer implements Runnable {

	Buffer buffer;

	public Consumer(Buffer buffer) {
		this.buffer = buffer;
	}

	@Override
	public void run() {
		// Allow to shutdown a producer by stopping the buffer or by sending an interrupt
		while (buffer.isRunning() && !Thread.currentThread().isInterrupted()) {
			buffer.consume();
		}
	}
}
