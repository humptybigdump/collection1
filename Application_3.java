/*
 * Copyright (c) 2024, KASTEL. All rights reserved.
 */

package edu.kit.kastel.dotsandboxes;

import edu.kit.kastel.dotsandboxes.logic.DotsAndBoxes;
import edu.kit.kastel.dotsandboxes.logic.InitialisationMode;
import edu.kit.kastel.dotsandboxes.logic.Initializer;
import edu.kit.kastel.dotsandboxes.logic.Player;
import edu.kit.kastel.dotsandboxes.view.UserInteraction;

/**
 * Main class as entry point of the application.
 *
 * @author Programmieren-Team
 */
public final class Application {

    private static final int ARGUMENT_INDEX_BOARD_LENGTH = 0;
    private static final int ARGUMENT_INDEX_INITIALIZATION_MODE = 1;
    private static final String PLAYER_NAME_FIRST = "A";
    private static final String PLAYER_NAME_SECOND = "B";

    private Application() {
        // utility class
    }

    /**
     * Entry point of the application.
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        int length = getLength(args);
        DotsAndBoxes game = Initializer.initialize(getMode(args[ARGUMENT_INDEX_INITIALIZATION_MODE]), length, 
                new Player(PLAYER_NAME_FIRST), new Player(PLAYER_NAME_SECOND));
        UserInteraction ui = new UserInteraction(game);
        ui.start();
    }

    private static int getLength(String[] args) {
        try {
            return Integer.parseInt(args[ARGUMENT_INDEX_BOARD_LENGTH]);
        } catch (NumberFormatException e) {
            // not needed to handle as it was given that provided inputs are valid
            return 0;
        }
    }

    private static InitialisationMode getMode(String representation) {
        for (InitialisationMode mode : InitialisationMode.values()) {
            if (mode.name().toLowerCase().equals(representation)) {
                return mode;
            }
        }
        return null;
    }
}
