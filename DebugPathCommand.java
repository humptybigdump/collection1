package edu.kit.kastel.commands;


import edu.kit.kastel.model.NavigationSystem;
import edu.kit.kastel.util.PathFinderResult;

import java.util.regex.Pattern;

/**
 * This command prints the shortest path to the destination.
 *
 * @author uezxa
 * @author udkdm
 */
public class DebugPathCommand extends Command {
    private static final Pattern PATTERN = Pattern.compile("^debug-path$");
    private static final String NO_PATH_FOUND = "FAIL";

    /**
     * Constructs a new debug-path command.
     *
     * @param handler          The command handler which is not used for this command
     * @param navigationSystem The navigation system to set the new map on it
     */
    public DebugPathCommand(CommandHandler handler, NavigationSystem navigationSystem) {
        super(PATTERN, handler, navigationSystem);
    }

    @Override
    public void execute(String[] arguments) {
        PathFinderResult result;
        try {
            result = this.navigationSystem.findPathToDestination();
        } catch (InvalidCommandArgumentException exception) {
            System.err.println(exception.getMessage());
            return;
        }

        if (result.isEmpty()) {
            System.out.println(NO_PATH_FOUND);
            return;
        }

        try {
            System.out.println(this.navigationSystem.debug(result.getCoordinates()));
        } catch (InvalidCommandArgumentException exception) {
            System.err.println(exception.getMessage());
        }
    }

}
