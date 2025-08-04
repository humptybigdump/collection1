package observer;

public class ConsoleObserver implements Observer {

    private final CounterSubject subject;

    public ConsoleObserver(CounterSubject subject) {
        this.subject = subject;
    }

    @Override
    public void update() {
        System.out.println("Counter just found a prime: " + subject.getCounter());
    }
}