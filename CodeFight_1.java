package codefight.model.game;

import codefight.model.ai.AiCommand;
import codefight.model.memory.Memory;
import codefight.model.player.Player;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents an instance of the game Code Fight.
 * @author ugmom
 */
public class CodeFight {

    private static final String ERROR_ONLY_DURING_GAME = "Method call outside the GAME_PHASE";
    private static final String UNKNOWN_PLAYER = "Received an invalid player which cannot be accepted";
    private static final String UNKNOWN_PARTICIPANTS = "Received an invalid list of participants which cannot be accepted";
    private static final String UNKNOWN_LOSERS = "Received an invalid list of losers which cannot be accepted";
    
    private final List<Player> playerList = new ArrayList<>();
    private List<Player> participants = new ArrayList<>();
    private List<Player> losers = new ArrayList<>();
    private Memory memory;
    private int turn;
    private Player currentPlayer;
    private Phase phase = Phase.INIT_PHASE;
    private Phase gameMode = Phase.INIT_MODE_STOP;
    
    /**
     * Creates a Code Fight game.
     * @param memoryLength is length of the memory.
     * @param memorySymbols is the symbols for the memory and players.
     * @param playerSymbols are the symbols of the players.
     */
    public CodeFight(int memoryLength, String[] memorySymbols, String[] playerSymbols) {
        this.memory = new Memory(memorySymbols, playerSymbols, memoryLength);
    }
    
    /**
     * Adds a player to the player list.
     * @param player is the player.
     */
    public void addPlayer(Player player) {
        playerList.add(player);
    }
    
    /**
     * Removes a player from the players list.
     * @param name is the name of the player.
     * @return false if player was not found, true if successful.
     */
    public boolean removePlayer(String name) {
        
        for (Player player : playerList) {
            if (player.getName().equals(name)) {
                playerList.remove(player);
                return true;
            }
        }
        return false;
    }

    /**
     * Gets the current game phase.
     * @return the current game phase.
     */
    public Phase getPhase() {
        return this.phase;
    }
    
    /**
     * Replaces phase with another phase.
     * @param phase is the new phase.
     */
    public void setPhase(Phase phase) {
        this.phase = phase;
    }
    
    /**
     * Gets the current game phase.
     * @return the current game phase.
     */
    public Phase getGameMode() {
        return this.gameMode;
    }
    
    /**
     * Sets the current phase.
     * @param phase is the new phase.
     * @throws IllegalArgumentException if the phase object is null.
     */
    public void setGameMode(Phase phase) {
        this.gameMode = phase;
    }
    
    /**
     * Gets the memory.
     * @return the memory.
     */
    public Memory getMemory() {
        return this.memory;
    }
    
    /**
     * Gets the current participants of the game.
     * @return the current participants of the game.
     */
    public List<Player> getParticipants() {
        return new ArrayList<>(participants);
    }
    
    /**
     * Sets the participants list.
     * @param participants is the participants list.
     * @throws IllegalArgumentException if the participants list is null.
     */
    public void setParticipants(List<Player> participants) {
        if (participants == null) {
            throw new IllegalArgumentException(UNKNOWN_PARTICIPANTS);
        }
        
        this.participants = participants;
    }
    
    /**
     * Finds the player based on the name and returns it.
     *
     * @param name is the name of the player.
     * @return the player object.
     */
    public Player findPlayer(String name) {
        
        for (Player player : playerList) {
            if (player.getName().equals(name)) {
                return player;
            }
        }
        return null;
    }
    
    /**
     * This class checks whether the player name already exists.
     *
     * @param name is the name of the player.
     * @return true if it exists, false otherwise
     */
    public boolean playerExists(String name) {
        
        for (Player player : playerList) {
            if (player.getName().equals(name)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Changes the current player.
     * @param currentPlayer is the new turn player.
     * @throws IllegalArgumentException if the player is null.
     */
    public void setCurrentPlayer(Player currentPlayer) {
        if (currentPlayer == null) {
            throw new IllegalArgumentException(UNKNOWN_PLAYER);
        }
        
        this.currentPlayer = currentPlayer;
    }
    
    /**
     * Gets the current player.
     *
     * @return the current player.
     */
    public Player getCurrentPlayer() {
        return this.currentPlayer;
    }
    /**
     * Goes to the next turn and updates the current player.
     */
    public void nextParticipant() {
        this.turn++;
        this.currentPlayer = participants.get(this.turn % this.participants.size());
    }
    
    /**
     * Finds the participant by its name.
     *
     * @param name is the name of the player.
     * @return the player.
     */
    public Player findParticipant(String name) {
        for (Player participant : participants) {
            if (participant.toString().equals(name)) {
                return participant;
            }
        }
        return null;
    }

    /**
     * Gets the current losers list.
     * @return the losers list.
     */
    public List<Player> getLosers() {
        return new ArrayList<>(this.losers);
    }

    /**
     * Sets the losers list.
     * @param losers the list of losers.
     * @throws IllegalArgumentException if the list is null.
     */
    public void setLosers(List<Player> losers) {
        if (losers == null) {
            throw new IllegalArgumentException(UNKNOWN_LOSERS);
        }
        this.losers = losers;
    }

    /**
     * Resets the memory.
     * @throws IllegalStateException if executed outside the game phase.
     */
    public void reset() {

        if (phase != Phase.GAME_PHASE) {
            throw new IllegalStateException(ERROR_ONLY_DURING_GAME);
        }

        this.participants.clear();
        this.losers.clear();

        for (Player player : playerList) {
            player.reset();
        }

        this.turn = 0;
        this.currentPlayer = null;
        this.phase = Phase.INIT_PHASE;
        this.memory = new Memory(this.memory.getMemorySymbols(), this.memory.getPlayerSymbols(), this.memory.getDeepMemory().length);

        if (this.gameMode == Phase.INIT_MODE_RANDOM) {
            long seed = Phase.INIT_MODE_RANDOM.getSeed();
            AiCommand.applySeed(this, seed);
        }

    }
}
