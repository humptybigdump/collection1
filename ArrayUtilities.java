package task3;

public class ArrayUtilities {
    public static boolean hasSubSequence131(int[] seq) {
        for (int i = 0; i < seq.length - 2; i++) {
            if (seq[i] == 1 && seq[i + 1] == 3 && seq[i + 2] == 1) {
                return true;
            }
        }
        return false;
    }
}
