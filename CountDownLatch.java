public class CountDownLatch {
    private int counter;

    public CountDownLatch(int counter) {
        this.counter = counter;
    }

    synchronized void await() throws InterruptedException {
        while (counter > 0) {
            wait();
        }
    }

    synchronized void countDown() {
        if(counter > 0) {
            counter--;
            if(counter == 0) {
                notifyAll();
            }
        }
    }

}



