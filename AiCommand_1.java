package codefight.model.ai;

import codefight.model.game.CodeFight;
import codefight.model.memory.MemoryCommand;
import codefight.model.player.Player;

import java.util.Optional;
import java.util.Random;

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
        public void execute(int ignored1, int ignored2, Player player, MemoryCommand[] ignored3) {
            player.stop();
        }
    },
    /**
     * Copies the command in source to target.
     * Source and target is based on the current position of the player.
     */
    MOV_R {
        @Override
        public void execute(int source, int target, Player player, MemoryCommand[] commandMemory) {
            int safeTarget = AiCommand.safeSearch(commandMemory.length, player.getPosition(), target);
            int safeSource = AiCommand.safeSearch(commandMemory.length, player.getPosition(), source);
            
            MemoryCommand newCommand = new MemoryCommand(commandMemory[safeSource]);
            commandMemory[safeTarget] = newCommand;
            AiCommand.commandEnd(newCommand, player, commandMemory.length);
            
        }
    },
    /**
     * Copies the command in source to target. Source command is based on the current position of the player.
     * Target depends on the second value of the command (also called intermediate) in the source index.
     */
    MOV_I {
        @Override
        public void execute(int source, int target, Player player, MemoryCommand[] commandMemory) {
            
            int safeSource = AiCommand.safeSearch(commandMemory.length, player.getPosition(), source);
            int safeTarget = AiCommand.safeSearch(commandMemory.length, player.getPosition(), target);
            
            int intermediateTarget = commandMemory[safeTarget].getValueB();
            int safeIntermediate = AiCommand.safeSearch(commandMemory.length, safeTarget, intermediateTarget);
            
            MemoryCommand newCommand = new MemoryCommand(commandMemory[safeSource]);
            commandMemory[safeIntermediate] = newCommand;
            AiCommand.commandEnd(newCommand, player, commandMemory.length);
            
        }
    },
    /**
     * Adds valueA to valueB.
     */
    ADD {
        @Override
        public void execute(int valueA, int valueB, Player player, MemoryCommand[] commandMemory) {
            MemoryCommand command = commandMemory[player.getPosition()];
            command.setValueB(valueA + valueB);
            AiCommand.commandEnd(command, player, commandMemory.length);
        }
    },
    /**
     * Adds valueA to valueB of the target. Target depends on the position of the player.
     */
    ADD_R {
        @Override
        public void execute(int valueA, int target, Player player, MemoryCommand[] commandMemory) {
            int safeTarget = AiCommand.safeSearch(commandMemory.length, player.getPosition(), target);
            
            int memoryTarget = commandMemory[safeTarget].getValueB();
            MemoryCommand targetCommand = commandMemory[safeTarget];
            targetCommand.setValueB(memoryTarget + valueA);
            AiCommand.commandEnd(targetCommand, player, commandMemory.length);
            
        }
    },
    /**
     * Player's current position is changed by newPosition.
     */
    JMP {
        @Override
        public void execute(int newPosition, int ignored, Player player, MemoryCommand[] commandMemory) {
            if (newPosition == 0) {
                player.executed();
                return;
            }
            int safePosition = AiCommand.safeSearch(commandMemory.length, player.getPosition(), newPosition);
            player.setPosition(safePosition);
            player.executed();
        
        }
    },
    /**
     * Jumps to the position given by target, but only if checkCell is 0.
     */
    JMZ {
        @Override
        public void execute(int target, int checkCellPos, Player player, MemoryCommand[] commandMemory) {
            int safeTarget = AiCommand.safeSearch(commandMemory.length, player.getPosition(), target);
            int safeCheckCellPos = AiCommand.safeSearch(commandMemory.length, player.getPosition(), checkCellPos);
            MemoryCommand checkCell = commandMemory[safeCheckCellPos];
            
            if (checkCell.getValueB() == 0) {
                player.setPosition(safeTarget);
                player.executed();
            } else {
                player.nextPosition(commandMemory.length);
                player.executed();
            }
        }
        
    },
    /**
     * Compares the first value of 'first' and the second value of 'second'.
     * If the values are unequal, then skip the next command, else do nothing.
     */
    CMP {
        @Override
        public void execute(int first, int second, Player player, MemoryCommand[] commandMemory) {
            int safeFirst = AiCommand.safeSearch(commandMemory.length, player.getPosition(), first);
            int safeSecond = AiCommand.safeSearch(commandMemory.length, player.getPosition(), second);
            
            int valueA = commandMemory[safeFirst].getValueA();
            int valueB = commandMemory[safeSecond].getValueB();
            
            if (valueA != valueB) {
                player.nextPosition(commandMemory.length);
            }

            player.nextPosition(commandMemory.length);
            player.executed();
        }
    },
    /**
     * Swaps valueA of the command in 'first' with valueB of the command in 'second'.
     * First and second depend on the position of the player.
     */
    SWAP {
        @Override
        public void execute(int first, int second, Player player, MemoryCommand[] commandMemory) {
            int safeFirst = AiCommand.safeSearch(commandMemory.length, player.getPosition(), first);
            int safeSecond = AiCommand.safeSearch(commandMemory.length, player.getPosition(), second);
            
            MemoryCommand source = commandMemory[safeFirst];
            MemoryCommand target = commandMemory[safeSecond];
            
            source.lastModifiedBy(player);
            target.lastModifiedBy(player);
            source.hasChanged();
            target.hasChanged();

            int valueA = source.getValueA();
            int valueB = target.getValueB();
            
            source.setValueA(valueB);
            target.setValueB(valueA);
            
            player.nextPosition(commandMemory.length);
            player.executed();
        }
    };

    private static final Player SYSTEM = new Player("SYSTEM", null);

    /**
     * Looks for an AiCommand object based on the name.
     *
     * @param name is the name of the command.
     * @return the matching enum or nothing if none has been found.
     */
    public static Optional<AiCommand> findByName(String name) {
        
        for (AiCommand command : values()) {
            if (command.name().equals(name)) {
                return Optional.of(command);
            }
        }
        
        return Optional.empty();
    }
    
    private static void commandEnd(MemoryCommand command, Player player, int memoryLength) {
        command.lastModifiedBy(player);
        command.hasChanged();
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
     * Applies the random memory based on the seed.
     * @param model is the game instance.
     * @param seed is the seed.
     */
    public static void applySeed(CodeFight model, long seed) {

        Random random = new Random(seed);
        String[] memory = model.getMemory().getDeepMemory();
        MemoryCommand[] commandMemory = model.getMemory().getCommandMemory();
        AiCommand[] aiCommands = AiCommand.values();
        int upperBound = aiCommands.length;

        for (int i = 0; i < memory.length; i++) {
            int randomAiCommandIndex = random.nextInt(upperBound);
            int randomValueA = random.nextInt();
            int randomValueB = random.nextInt();

            MemoryCommand newCommand = new MemoryCommand(aiCommands[randomAiCommandIndex],
                    randomValueA, randomValueB);
            newCommand.lastModifiedBy(SYSTEM);
            commandMemory[i] = newCommand;
        }

        model.getMemory().setMemory(memory);
        model.getMemory().setCommandMemory(commandMemory);

    }
    
    /**
     * Represents a necessary method which each AiCommand should have, which has its essential functionality.
     *
     * @param valueA is an arbitrary integer.
     * @param valueB is an arbitrary integer.
     * @param player is the player.
     * @param commandMemory is the memory with commands.
     */
    public abstract void execute(int valueA, int valueB, Player player, MemoryCommand[] commandMemory);
    
}
