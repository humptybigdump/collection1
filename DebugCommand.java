package edu.kit.kastel.commands;

import edu.kit.kastel.model.NavigationSystem;

import java.util.List;
import java.util.regex.Pattern;

/**
 * This command visualizes the terrain that the rover is currently on.
 * The terrain information is retrieved using the {@link NavigationSystem}.
 *
 * @author uezxa
 * @author udkdm
 */
public class DebugCommand extends Command {
    private static final Pattern PATTERN = Pattern.compile("^debug$");

    /**
     * Constructs a new {@code DebugCommand}.
     *
     * @param handler The {@link CommandHandler}, which is not used for this command
     * @param navigationSystem The {@link NavigationSystem} used to retrieve terrain information
     */
    public DebugCommand(CommandHandler handler, NavigationSystem navigationSystem) {
        super(PATTERN, handler, navigationSystem);
    }

    @Override
    public void execute(String[] arguments) {
        try {
            System.out.println(this.navigationSystem.debug(List.of()));
        } catch (InvalidCommandArgumentException exception) {
            System.err.println(exception.getMessage());
        }
    }
}
