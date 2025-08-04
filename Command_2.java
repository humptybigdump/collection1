/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */
package command;

import model.SussySorter;


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
    CommandResult execute(SussySorter model, String[] commandArguments);
}
