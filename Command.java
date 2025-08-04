/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */
package codefight.command;

import codefight.model.CodeFight;
import codefight.model.game.Phase;

/**
 * This interface represents an executable command.
 *
 * @author Programmieren-Team
 */
public interface Command {
    
    /**
     * Executes the command.
     *
     * @param model            the model to execute the command on
     * @param commandArguments the arguments of the command
     * @return the result of the command
     */
    CommandResult execute(CodeFight model, String[] commandArguments);
    
    /**
     * Returns the functionality of the command.
     *
     * @return the help message.
     */
    String getHelpMessage();
    
    /**
     * Returns the phase for which this command is relevant.
     *
     * @return the phase
     */
    Phase getPhase();

    /**
     * Specifies how many arguments the command must receive.
     * @return an {@code int} representing the number of arguments, but if {@code -1} then the amount is variable
     */
    int requiredArguments();
}
