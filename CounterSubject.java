package observer;

import java.util.stream.IntStream;

public class CounterSubject extends Subject {

    // subject state
    private int counter;

    public CounterSubject() {
        this.counter = 0;
    }

    public void count() {
        counter++;

        if (isPrime(counter)) {
            notifyObservers();
        }
    }

    // Copy & Paste: https://www.baeldung.com/java-prime-numbers
    private boolean isPrime(int number) {
        return number > 1 &&
                IntStream.rangeClosed(2, (int) Math.sqrt(number))
                        .noneMatch(n -> (number % n == 0));
    }

    public int getCounter() {
        return counter;
    }
}
