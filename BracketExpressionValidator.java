package task2;

import java.util.Stack;

public final class BracketExpressionValidator {
    private static final char[] OPENED_BRACKETS = {'(', '{', '['};
    private static final char[] CLOSED_BRACKETS = {')', '}', ']'};

    private BracketExpressionValidator() {
        throw new AssertionError("Utility class cannot be instantiated.");
    }

    public static boolean validate(String bracketExpression) {
        // Use a stack to track opened brackets.
        Stack<Character> stack = new Stack<>();

        // Iterate through all brackets in the given expression
        for (char bracket : bracketExpression.toCharArray()) {
            if (isOpenedBracket(bracket)) {
                stack.push(bracket);
            } else if (isClosedBracket(bracket)) {
                if (stack.isEmpty()) {
                    return false;
                }
                if (!isMatchingPair(stack.pop(), bracket)) {
                    return false;
                }
            }
        }
        // The stack should be empty if the expression is valid.
        return stack.isEmpty();
    }

    private static boolean isMatchingPair(char openedBracket, char closedBracket) {
        for (int i = 0; i < OPENED_BRACKETS.length; i++) {
            if (openedBracket == OPENED_BRACKETS[i] && closedBracket == CLOSED_BRACKETS[i]) {
                return true;
            }
        }
        return false;
    }

    private static boolean isOpenedBracket(char bracket) {
        for (char openedBracket : OPENED_BRACKETS) {
            if (bracket == openedBracket) return true;
        }
        return false;
    }

    private static boolean isClosedBracket(char bracket) {
        for (char closedBracket : CLOSED_BRACKETS) {
            if (bracket == closedBracket) return true;
        }
        return false;
    }
}
