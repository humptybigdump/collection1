package edu.kit.kastel.commands;

import edu.kit.kastel.model.NavigationSystem;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Scanner;


/**
 * This class handles the registration, processing, and execution of commands in the application.
 * It acts as the central interface for user interaction, matching input to commands and delegating execution.
 *
 * @author uezxa
 * @author udkdm
 */
public class CommandHandler {
    private final List<Command> commands = new ArrayList<>();
    private final Scanner scanner = new Scanner(System.in);
    private final NavigationSystem navigationSystem;

    private boolean running;
    private int remainingTerrainLines = 0;

    /**
     * Constructs a new command handler.
     *
     * @param navigationSystem The navigations system to handle commands for
     */
    public CommandHandler(NavigationSystem navigationSystem) {
        this.navigationSystem = Objects.requireNonNull(navigationSystem);
        initializeCommands();
        this.running = true;
    }

    /**
     * This method handles the user interaction.
     */
    public void handleInput() {
        while (this.running) {
            final String input = getInput();
            // Try to match the input to an existing command.
            try {
                Command.executeCommand(input, this.commands);
            } catch (InvalidCommandArgumentException exception) {
                // Check if the "new" command is still in progress.
                if (this.remainingTerrainLines > 0) {
                    this.remainingTerrainLines--;
                    continue;
                }
                System.err.println(exception.getMessage());
            }
        }
        this.scanner.close();
    }

    /**
     * Gets an input line from the user.
     *
     * @return The scanned line from the user
     */
    public String getInput() {
        return this.scanner.nextLine();
    }

    /**
     * Quits the command handler.
     */
    public void quit() {
        this.running = false;
    }

    /**
     * This method is called by the new terrain command and indicates how many lines it still needs to read.
     *
     * @param remainingTerrainLines The remaining lines needed for a valid new terrain
     */
    public void setRemainingTerrainLines(int remainingTerrainLines) {
        this.remainingTerrainLines = remainingTerrainLines;
    }

    private void initializeCommands() {
        this.commands.add(new NewTerrainCommand(this, this.navigationSystem));
        this.commands.add(new MoveCommand(this, this.navigationSystem));
        this.commands.add(new DebugCommand(this, this.navigationSystem));
        this.commands.add(new PathCommand(this, this.navigationSystem));
        this.commands.add(new DebugPathCommand(this, this.navigationSystem));
        this.commands.add(new QuitCommand(this, this.navigationSystem));
    }
}
