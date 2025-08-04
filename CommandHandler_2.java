
/*
Copyright (c) 2024, KASTEL. All rights reserved.
 */

package command;

import model.SussySorter;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

/**
 * This class handles the user input and executes the commands.
 *
 * @author Programmieren-Team
 */
public class CommandHandler {
    
    
    private static final String COMMAND_SEPARATOR_REGEX = " +";
    private static final String ERROR_PREFIX = "ERROR: ";
    private static final String ERROR_COMMAND_NOT_FOUND = "Command '%s' not found!";
    private static final String PREFIX_UNEXPECTED_VALUE = "Unexpected value: ";
    private static final String LOAD_COMMAND = "load";
    private static final String CHANGE_COMMAND = "change";
    private static final String RUN_COMMAND = "run";
    private static final String QUIT_COMMAND = "quit";
    private final SussySorter sussySorter;
    private final Map<String, Command> commands;
    private boolean isRunning = false;

    /**
     * Constructs a new CommandHandler.
     *
     * @param sussySorter is the sorter instance.
     */
    public CommandHandler(SussySorter sussySorter) {
        this.sussySorter = sussySorter;
        this.commands = new HashMap<>();
        this.initCommands();
    }

    /**
     * Starts the interaction with the user.
     */
    public void handleUserInput() {
        this.isRunning = true;

        try (Scanner scanner = new Scanner(System.in)) {
            while (isRunning && scanner.hasNextLine()) {
                executeCommand(scanner.nextLine());
            }
        }
    }

    /**
     * Quits the interaction with the user.
     */
    public void quit() {
        this.isRunning = false;
    }

    private void executeCommand(String commandWithArguments) {
        String[] splittedCommand = commandWithArguments.trim().split(COMMAND_SEPARATOR_REGEX);
        String commandName = splittedCommand[0];
        String[] commandArguments = Arrays.copyOfRange(splittedCommand, 1, splittedCommand.length);

        executeCommand(commandName, commandArguments);
    }

    private void executeCommand(String commandName, String[] commandArguments) {
        if (!commands.containsKey(commandName)) {
            System.err.println(ERROR_PREFIX + ERROR_COMMAND_NOT_FOUND.formatted(commandName));
        } else {
            CommandResult result = commands.get(commandName).execute(sussySorter, commandArguments);
            String output = switch (result.getType()) {
                case SUCCESS -> result.getMessage();
                case FAILURE -> ERROR_PREFIX + result.getMessage();
            };
            if (output != null) {
                switch (result.getType()) {
                    case SUCCESS -> System.out.println(output);
                    case FAILURE -> System.err.println(output);
                    default -> throw new IllegalStateException(PREFIX_UNEXPECTED_VALUE + result.getType());
                }
            }
        }
    }

    private void initCommands() {
        this.addCommand(LOAD_COMMAND, new LoadCommand());
        this.addCommand(CHANGE_COMMAND, new ChangeCommand());
        this.addCommand(RUN_COMMAND, new RunCommand());
        this.addCommand(QUIT_COMMAND, new QuitCommand(this));
    }

    private void addCommand(String commandName, Command command) {
        this.commands.put(commandName, command);
    }
}
