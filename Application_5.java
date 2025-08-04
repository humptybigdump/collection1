
package codefight;

import codefight.model.CodeFight;
import codefight.command.CommandHandler;

import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * This class is the entry-point of the program.
 *
 * @author ugmom
 */
public final class Application {
    
    private static final int MEMORY_LENGTH_INDEX = 0;
    private static final int MIN_LENGTH = 7;
    private static final int MAX_LENGTH = 1337;
    private static final int INDEPENDENT_AI_SYMBOLS = 4;
    private static final int MIN_ARGUMENT_LENGTH = 4;
    private static final String INVALID_LENGTH_FORMAT = "Error, length must be within [7,1337] (received: %d)%n";
    private static final String INVALID_ARGUMENT = "Error, unexpected value (%s)%n";
    private static final String MISSING_SYMBOLS = "Error, min. of 4 single symbols required!";
    private static final String MISSING_PLAYER_SYMBOLS = "Error, a player doesn't have two individual symbols";
    private static final String ERROR_UNIQUENESS = "Error, the symbols aren't unique";
    private static final String ERROR_NO_COMMANDS = "Error, no arguments could be read";
    private static final String UTILITY_CLASS_CONSTRUCTOR_MESSAGE = "Utility classes cannot be instantiated";
    
    private Application() {
        throw new UnsupportedOperationException(UTILITY_CLASS_CONSTRUCTOR_MESSAGE);
    }
    
    /**
     * Starts the program.
     *
     * @param args 1 {@code memoryLength} 2 {@code memoryBorder} 3 {@code nextAI} 4 {@code nextAIs} 5 {@code standardAI} 6 {@code AIBomb}
     */
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println(ERROR_NO_COMMANDS);
            return;
        }

        int memoryLength;
        try {
            memoryLength = Integer.parseInt(args[MEMORY_LENGTH_INDEX]);
        } catch (NumberFormatException e) {
            System.err.printf(INVALID_ARGUMENT, args[MEMORY_LENGTH_INDEX]);
            return;
        }
        if (memoryLength < MIN_LENGTH || memoryLength > MAX_LENGTH) {
            System.err.printf(INVALID_LENGTH_FORMAT, memoryLength);
            return;
        }
        if (args.length <= MIN_ARGUMENT_LENGTH) {
            System.err.println(MISSING_SYMBOLS);
            return;
        }

        String[] symbols = Arrays.copyOfRange(args, 1, INDEPENDENT_AI_SYMBOLS + 1);
        String[] playerSymbols = parsePlayerSymbols(args);

        if (playerSymbols == null) {
            System.err.println(MISSING_PLAYER_SYMBOLS);
            return;
        }

        if (!isUnique(args)) {
            System.err.println(ERROR_UNIQUENESS);
            return;
        }
        
        CodeFight codeFight = new CodeFight(memoryLength, symbols, playerSymbols);
        CommandHandler commandHandler = new CommandHandler(codeFight);
        commandHandler.handleUserInput();
        
    }

    private static boolean isUnique(String[] arguments) {
        // If a list has duplicate arguments, then the Set of that list must be smaller
        return Arrays.stream(arguments).collect(Collectors.toSet()).size() == arguments.length;
    }
    
    private static String[] parsePlayerSymbols(String[] args) {
        // Check if there are two symbols for each AI player
        return (args.length - INDEPENDENT_AI_SYMBOLS - 1) % 2 != 0
                ? null : Arrays.copyOfRange(args, INDEPENDENT_AI_SYMBOLS + 1, args.length);
    }
}
