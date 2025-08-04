
/*
Copyright (c) 2024, KASTEL. All rights reserved.
 */

package codefight.command;

import codefight.model.game.CodeFight;

import java.util.Map;
import java.util.HashMap;
import java.util.Scanner;
import java.util.Arrays;

/**
 * This class handles the user input and executes the commands.
 *
 * @author Programmieren-Team
 */
public class CommandHandler {
    private static final String COMMAND_SEPARATOR_REGEX = " +";
    private static final String ERROR_PREFIX = "Error, ";
    private static final String ERROR_COMMAND_NOT_FOUND = "Command '%s' not found!";
    private static final String PREFIX_UNEXPECTED_VALUE = "Unexpected value: ";

    private static final String ADD_AI_COMMAND = "add-ai";
    private static final String REMOVE_AI_COMMAND = "remove-ai";
    private static final String SET_INIT_MODE_COMMAND = "set-init-mode";
    private static final String START_GAME_COMMAND = "start-game";
    private static final String NEXT_COMMAND = "next";
    private static final String SHOW_MEMORY = "show-memory";
    private static final String SHOW_AI_COMMAND = "show-ai";
    private static final String END_GAME_COMMAND = "end-game";
    private static final String QUIT_COMMAND = "quit";
    private static final String HELP_COMMAND = "help";

    private final CodeFight codeFight;
    private final Map<String, Command> commands;
    private boolean isRunning = false;

    /**
     * Constructs a new CommandHandler.
     *
     * @param codeFight is the game instance
     */
    public CommandHandler(CodeFight codeFight) {
        this.codeFight = codeFight;
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

            CommandResult result = commands.get(commandName).execute(codeFight, commandArguments);
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
        this.addCommand(QUIT_COMMAND, new QuitCommand(this));
        this.addCommand(ADD_AI_COMMAND, new AddAiCommand());
        this.addCommand(REMOVE_AI_COMMAND, new RemoveAiCommand());
        this.addCommand(SET_INIT_MODE_COMMAND, new SetInitModeCommand());
        this.addCommand(START_GAME_COMMAND, new StartGameCommand());
        this.addCommand(NEXT_COMMAND, new NextCommand());
        this.addCommand(SHOW_MEMORY, new ShowMemoryCommand());
        this.addCommand(SHOW_AI_COMMAND, new ShowAiCommand());
        this.addCommand(END_GAME_COMMAND, new EndGameCommand());
        this.addCommand(HELP_COMMAND, new HelpCommand(this));

    }

    private void addCommand(String commandName, Command command) {
        this.commands.put(commandName, command);
    }
    
    /**
     * Returns the map of commands.
     *
     * @return the map of commands.
     */
    public Map<String, Command> getCommands() {
        return new HashMap<>(commands);
    }
}
