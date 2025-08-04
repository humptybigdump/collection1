package edu.kit.kastel.commands;

import edu.kit.kastel.model.NavigationSystem;

import java.util.List;
import java.util.Objects;
import java.util.regex.Pattern;

/**
 * This class acts like a base for all commands.
 *
 * @author uezxa
 * @author udkdm
 */
public abstract class Command {
    /**
     * The index of the command itself in the arguments array.
     */
    protected static final int ARGUMENTS_COMMAND_INDEX = 0;

    /**
     * The default length of the arguments array if the command has no further arguments.
     */
    protected static final int ARGUMENTS_DEFAULT_LENGTH = 1;

    /**
     * The message that is printed when an error occurs.
     */
    protected static final String ERROR_MESSAGE = "ERROR";

    private static final String SEPARATOR = "\\s+";

    protected final Pattern pattern;
    protected final CommandHandler handler;
    protected final NavigationSystem navigationSystem;

    /**
     * Constructs a new command.
     *
     * @param pattern The pattern of the command
     * @param handler The command handler to access it when quitting the user interaction
     * @param navigationSystem The navigation system to access it while executing the command
     */
    Command(Pattern pattern, CommandHandler handler, NavigationSystem navigationSystem) {
        this.pattern = Objects.requireNonNull(pattern);
        this.handler = Objects.requireNonNull(handler);
        this.navigationSystem = Objects.requireNonNull(navigationSystem);
    }

    /**
     * Returns the pattern this command uses for matching input.
     *
     * @return A Pattern object representing the command's input format.
     */
    public Pattern getPattern() {
        return this.pattern;
    }

    /**
     * Finds and executes the first matching {@link Command} from the list of commands based on the input.
     *
     * @param input The user input string to match against commands
     * @param commands The list of available commands to check
     * @throws InvalidCommandArgumentException If no matching command is found
     */
    public static void executeCommand(String input, List<Command> commands) throws InvalidCommandArgumentException {
        // Check if at least one
        for (Command command : commands) {
            if (command.getPattern().matcher(input).matches()) {
                command.execute(input.split(SEPARATOR));
                return;
            }
        }
        throw new InvalidCommandArgumentException();
    }

    /**
     * Executes the command with the given arguments.
     *
     * @param arguments The arguments of the command
     */
    public abstract void execute(String[] arguments);
}
