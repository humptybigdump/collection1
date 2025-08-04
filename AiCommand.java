package codefight.model.memory;

import codefight.model.CodeFight;
import codefight.model.player.Player;

import java.util.Collections;
import java.util.List;

/**
 * Represents all possible commands which the AI can execute.
 *
 * @author ugmom
 */
public enum AiCommand {
    
    
    /**
     * Represents the command which makes the player lose.
     */
    STOP {
        @Override
        public List<Player> execute(int ignored1, int ignored2, Player player, CodeFight ignored3) {
            player.stop();
            return List.of(player);
        }
    },
    /**
     * Copies the command in source to target.
     * Source and target is based on the current position of the player.
     */
    MOV_R {
        @Override
        public List<Player> execute(int source, int target, Player player, CodeFight model) {
            int safeTarget = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), target);
            int safeSource = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), source);

            MemoryCell cell = model.getCommand(safeSource);
            MemoryCommand newCommand = new MemoryCommand(cell.getMemoryCommand());
            model.changeCommand(safeTarget, newCommand);
            AiCommand.commandEnd(cell, player, model.getMemoryLength());
            return Collections.emptyList();
        }
    },
    /**
     * Copies the command in source to target. Source command is based on the current position of the player.
     * Target depends on the second value of the command (also called intermediate) in the source index.
     */
    MOV_I {
        @Override
        public List<Player> execute(int source, int target, Player player, CodeFight model) {
            
            int safeSource = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), source);
            int safeTarget = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), target);

            int intermediateTarget = model.getCommand(safeTarget).getMemoryCommand().getValueB();
            int safeIntermediate = AiCommand.safeSearch(model.getMemoryLength(), safeTarget, intermediateTarget);

            MemoryCell cell = model.getCommand(safeSource);
            MemoryCommand newCommand = new MemoryCommand(cell.getMemoryCommand());
            model.changeCommand(safeIntermediate, newCommand);
            model.getCommand(safeIntermediate).changeModifier(player);
            player.nextPosition(model.getMemoryLength());
            player.executed();
            cell.reveal();
            return Collections.emptyList();
        }
    },
    /**
     * Adds valueA to valueB.
     */
    ADD {
        @Override
        public List<Player> execute(int valueA, int valueB, Player player, CodeFight model) {
            MemoryCell cell = model.getCommand(player.getPosition());
            MemoryCommand command = cell.getMemoryCommand();
            command.setValueB(valueA + valueB);
            AiCommand.commandEnd(cell, player, model.getMemoryLength());
            return Collections.emptyList();
        }
    },
    /**
     * Adds valueA to valueB of the target. Target depends on the position of the player.
     */
    ADD_R {
        @Override
        public List<Player> execute(int valueA, int target, Player player, CodeFight model) {
            int safeTarget = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), target);
            int memoryTarget = model.getCommand(safeTarget).getMemoryCommand().getValueB();

            MemoryCell cell = model.getCommand(safeTarget);
            MemoryCommand targetCommand = cell.getMemoryCommand();
            targetCommand.setValueB(memoryTarget + valueA);
            AiCommand.commandEnd(cell, player, model.getMemoryLength());
            return Collections.emptyList();
        }
    },
    /**
     * Player's current position is changed by newPosition.
     */
    JMP {
        @Override
        public List<Player> execute(int newPosition, int ignored, Player player, CodeFight model) {
            if (newPosition == 0) {
                player.executed();
                return Collections.emptyList();
            }
            int safePosition = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), newPosition);
            player.setPosition(safePosition);
            player.executed();
            return Collections.emptyList();
        }
    },
    /**
     * Jumps to the position given by target, but only if checkCell is 0.
     */
    JMZ {
        @Override
        public List<Player> execute(int target, int checkCellPos, Player player, CodeFight model) {
            int safeTarget = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), target);
            int safeCheckCellPos = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), checkCellPos);
            MemoryCommand checkCell = model.getCommand(safeCheckCellPos).getMemoryCommand();

            if (checkCell.getValueB() == 0) {
                player.setPosition(safeTarget);
                player.executed();
            } else {
                player.nextPosition(model.getMemoryLength());
                player.executed();
            }
            return Collections.emptyList();
        }
        
    },
    /**
     * Compares the first value of 'first' and the second value of 'second'.
     * If the values are unequal, then skip the next command, else do nothing.
     */
    CMP {
        @Override
        public List<Player> execute(int first, int second, Player player, CodeFight model) {
            int safeFirst = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), first);
            int safeSecond = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), second);
            
            int valueA = model.getCommand(safeFirst).getMemoryCommand().getValueA();
            int valueB = model.getCommand(safeSecond).getMemoryCommand().getValueB();
            
            if (valueA != valueB) {
                player.nextPosition(model.getMemoryLength());
            }

            player.nextPosition(model.getMemoryLength());
            player.executed();
            return Collections.emptyList();
        }
    },
    /**
     * Swaps valueA of the command in 'first' with valueB of the command in 'second'.
     * First and second depend on the position of the player.
     */
    SWAP {
        @Override
        public List<Player> execute(int first, int second, Player player, CodeFight model) {
            int safeFirst = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), first);
            int safeSecond = AiCommand.safeSearch(model.getMemoryLength(), player.getPosition(), second);

            MemoryCell source = model.getCommand(safeFirst);
            MemoryCell target = model.getCommand(safeSecond);

            int valueA = source.getMemoryCommand().getValueA();
            int valueB = target.getMemoryCommand().getValueB();

            source.reveal();
            source.changeModifier(player);
            source.getMemoryCommand().setValueB(valueB);
            target.reveal();
            target.changeModifier(player);
            target.getMemoryCommand().setValueA(valueA);
            
            player.nextPosition(model.getMemoryLength());
            player.executed();
            return Collections.emptyList();
        }
    };

    /**
     * Looks for an AiCommand object based on the name.
     *
     * @param name is the name of the command.
     * @return the matching enum or nothing if none has been found.
     */
    public static AiCommand findByName(String name) {
        
        for (AiCommand command : values()) {
            if (command.name().equals(name)) {
                return command;
            }
        }
        
        return null;
    }
    
    private static void commandEnd(MemoryCell cell, Player player, int memoryLength) {
        cell.reveal();
        cell.changeModifier(player);
        player.nextPosition(memoryLength);
        player.executed();
    }
    
    private static int safeSearch(int memoryLength, int position, int index) {
        
        int newPosition = position + index;
        
        if (newPosition < 0) {
            return (memoryLength + position + (index % memoryLength)) % memoryLength;
        } else if (newPosition >= memoryLength) {
            return newPosition % memoryLength;
        } else {
            return newPosition;
        }
    }
    
    /**
     * Represents a necessary method which each AiCommand should have, which has its essential functionality.
     *
     * @param valueA is an arbitrary integer
     * @param valueB is an arbitrary integer
     * @param player is the player
     * @param model is the game
     * @return list of players that have been stopped as a result
     */
    public abstract List<Player> execute(int valueA, int valueB, Player player, CodeFight model);
}
