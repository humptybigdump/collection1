package task1;

import java.util.StringJoiner;

public final class ArrayPrinter {
    private static final String ELEMENT_SEPARATOR = ", ";

    private ArrayPrinter() {
        throw new AssertionError("Utility class cannot be instantiated.");
    }

    public static <T> void print(T[] array) {
        StringJoiner joiner = new StringJoiner(ELEMENT_SEPARATOR);
        for (T element : array) {
            joiner.add(element.toString());
        }
        System.out.println(joiner);
    }
}