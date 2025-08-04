package codefight.model;

import codefight.model.game.Phase;
import codefight.model.game.PhaseHandler;
import codefight.model.memory.Memory;
import codefight.model.memory.MemoryCell;
import codefight.model.memory.MemoryCommand;
import codefight.model.player.Player;
import codefight.model.player.PlayerHandler;
import codefight.model.player.PlayerProvider;
import codefight.model.player.PlayerRequest;

import java.util.Iterator;
import java.util.List;

/**
 * Represents an instance of the game Code Fight.
 * @author ugmom
 */
public class CodeFight implements Iterable<MemoryCell> {
    private final Memory memory;
    private final PlayerHandler playerHandler;
    private final PhaseHandler phaseHandler;

    /**
     * Creates a Code Fight game.
     * @param memoryLength is length of the memory.
     * @param memorySymbols is the symbols for the memory and players.
     * @param playerSymbols are the symbols of the players.
     */
    public CodeFight(int memoryLength, String[] memorySymbols, String[] playerSymbols) {
        this.memory = new Memory(memorySymbols, playerSymbols, memoryLength);
        this.playerHandler = new PlayerHandler();
        this.phaseHandler = new PhaseHandler(Phase.INIT_PHASE, Phase.INIT_MODE_STOP);
        PlayerHandler.getSystem().setSymbol(memorySymbols[0]);
        PlayerHandler.getSystem().setBomb(memorySymbols[0]);
    }

    /**
     * Removes a player from the players list.
     * @param name is the name of the player.
     * @return false if player was not found, true if successful.
     */
    public boolean removePlayer(String name) {
        return playerHandler.removePlayer(playerHandler.findPlayer(name));
    }

    /**
     * Checks if the player is already in the catalogue.
     * @param player is the player
     * @return {@code true} if present {@code false} otherwise
     */
    public boolean playerExists(Player player) {
        return playerHandler.exists(player);
    }

    /**
     * Gets the current game phase.
     * @return the current game phase.
     */
    public Phase getPhase() {
        return phaseHandler.getPhase();
    }

    /**
     * Replaces phase with another phase.
     * @param phase is the new phase.
     */
    public void changePhase(Phase phase) {
        phaseHandler.setPhase(phase);
        if (phase == Phase.GAME_PHASE) {
            playerHandler.startGame();
        }
    }

    /**
     * Gets the current game phase.
     * @return the current game phase.
     */
    public Phase getGameMode() {
        return phaseHandler.getGameMode();
    }

    /**
     * Sets the current phase.
     * @param phase is the new phase.
     */
    public void setGameMode(Phase phase) {
        phaseHandler.setGameMode(phase);
    }

    /**
     * Gets the array of player symbols.
     * @return the array of player symbols
     */
    public String[] getPlayerSymbols() {
        return this.memory.getPlayerSymbols();
    }

    /**
     * Gets the symbols for the memory.
     * @return the symbols for the memory
     */
    public String[] getMemorySymbols() {
        return memory.getMemorySymbols();
    }

    /**
     * Gets the list of participants.
     * @return the list of participants
     */
    public List<Player> getParticipants() {
        return playerHandler.getParticipants();
    }

    /**
     * Applies the provided seed onto the memory.
     * @param gameMode is the new game mode
     * @param seed is the new seed
     */
    public void applySeed(Phase gameMode, int seed) {
        memory.setSeed(seed);
        memory.applySeed(gameMode);
    }

    /**
     * Gets the current seed of the game.
     * @return the current seed
     */
    public int getSeed() {
        return memory.getSeed();
    }

    /**
     * Gets the memory cell in the specified index.
     * @param index is the index of the memory cell
     * @return the requested memory cell
     */
    public MemoryCell getCommand(int index) {
        return memory.get(index);
    }

    /**
     * Modifies changes the command in the specified index.
     * @param index is the index of the memory cell
     * @param command is the new command
     */
    public void changeCommand(int index, MemoryCommand command) {
        memory.changeCommand(index, command);
    }

    /**
     * Gets the length of the memory.
     * @return the length of the memory
     */
    public int getMemoryLength() {
        return memory.length();
    }

    /**
     * Executes the memory command on the current position (depending on the player).
     * @param player is the current player
     * @return list of the players that stopped as a result
     */
    public List<Player> executeMemory(Player player) {
        if (player.hasStopped()) {
            return List.of(player);
        }
        MemoryCommand command = memory.get(player.getPosition()).getMemoryCommand();
        return command.getAiCommand().execute(command.getValueA(), command.getValueB(), player, this);
    }

    /**
     * Gets the presentation of the memory.
     * @param applyNextPlayers ensures that the next players are displayed correctly
     * @return the memory representation
     */
    public String memoryRepresentation(boolean applyNextPlayers) {
        return memory.getRepresentation(playerHandler.getCurrentPlayer(), playerHandler.getParticipants(), applyNextPlayers);
    }

    /**
     * Gets the representation of the memory with boundaries.
     * @param range is the range of the memory
     * @param applyNextPlayers ensures that the next players displayed correctly
     * @return the memory representation with boundaries
     */
    public String boundedMemoryRepresentation(int range, boolean applyNextPlayers) {
        return memory.getBoundedRepresentation(playerHandler.getCurrentPlayer(), playerHandler.getParticipants(), range, applyNextPlayers);
    }

    /**
     * Checks if any players are still alive.
     * @return {@code true} if there still are players running {@code false} otherwise
     */
    public boolean stillAlive() {
        return playerHandler.stillRunning();
    }


    /**
     * Resets the memory.
     * @throws IllegalStateException if executed outside the game phase.
     */
    public void reset() {
        int seed = memory.getSeed();

        playerHandler.reset();
        phaseHandler.reset();
        memory.reset();

        if (phaseHandler.getGameMode() == Phase.INIT_MODE_RANDOM) {
            applySeed(Phase.INIT_MODE_RANDOM, seed);
        }

    }

    /**
     * Executes a player request.
     * @param request is the request
     */
    public void executePlayerRequest(PlayerRequest request) {
        request.execute(playerHandler);
    }

    /**
     * Provides a player.
     * @param provider is the provider
     * @return the player
     */
    public Player providePlayer(PlayerProvider provider) {
        return provider.provide(playerHandler);
    }

    @Override
    public Iterator<MemoryCell> iterator() {
        return memory.iterator();
    }
}
