package codefight.command;

import codefight.model.game.CodeFight;
import codefight.model.game.Phase;
import codefight.model.player.Player;
import codefight.model.ai.AiCommand;
import codefight.model.memory.MemoryCommand;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Optional;

/**
 * Represents the "add-ai" command.
 *
 * @author ugmom
 */
final class AddAiCommand implements Command {
    
    private static final int REQUIRED_ARGS_LENGTH = 2;
    private static final int REQUIRED_COMMAND_LENGTH = 3;
    private static final int AI_NAME_INDEX = 0;
    private static final int AI_COMMANDS = 1;
    private static final int NEXT_COMMAND_INCREMENT = 3;
    private static final int FIRST_ARGUMENT_INCREMENT = 1;
    private static final int SECOND_ARGUMENT_INCREMENT = 2;
    private static final int MIN_PLAYERS = 2;
    
    private static final String REGEX_COMMAND_SEPARATOR = ",";
    private static final String ERROR_OVERLAP = "due to insufficient space, the commands will overlap";
    private static final String ERROR_ILLEGAL_STATE = "this command can only executed in the %s";
    private static final String ERROR_INCOMPLETE_LIST = "the list of commands is incomplete!";
    private static final String ERROR_INVALID_ARGUMENTS = "invalid commands/arguments";
    private static final String ERROR_DUPLICATE_PLAYER_NAME = "'%s' is already being used";
    private static final String ERROR_ONLY_STOPS = "'%s' only contains STOP commands";
    private static final String ERROR_ARGS = "wrong number of arguments (expected: %d)";
    
    private static final String HELP_MESSAGE = "Adds an AI";
    private final Phase phase = Phase.INIT_PHASE;
    
    @Override
    public CommandResult execute(CodeFight model, String[] commandArguments) {
        
        if (phase != model.getPhase()) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_ILLEGAL_STATE.formatted(phase.name()));
        } else if (commandArguments.length != REQUIRED_ARGS_LENGTH) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_ARGS.formatted(REQUIRED_ARGS_LENGTH));
        }
        
        String[] commandLine = commandArguments[AI_COMMANDS].trim().split(REGEX_COMMAND_SEPARATOR);
        if (commandLine.length % REQUIRED_COMMAND_LENGTH != 0) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_INCOMPLETE_LIST);
        }
        
        Collection<MemoryCommand> commands = parseMemoryCommands(commandLine);
        String aiName = commandArguments[AI_NAME_INDEX];
        
        if (commands == null) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_INVALID_ARGUMENTS);
        } else if (onlyStopCommands(commands)) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_ONLY_STOPS.formatted(aiName));
        }
        int memoryLength = model.getMemory().getMemoryLength();
        Player player = new Player(aiName, commands);
        if (commands.size() - 1 > memoryLength / MIN_PLAYERS) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_OVERLAP);
        }
        if (model.playerExists(aiName)) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_DUPLICATE_PLAYER_NAME.formatted(aiName));
        }
        model.addPlayer(player);
        return new CommandResult(CommandResultType.SUCCESS, aiName);
    }
    
    private boolean onlyStopCommands(Collection<MemoryCommand> commands) {
        boolean onlyStops = true;
        
        for (MemoryCommand command : commands) {
            if (!command.getAiCommand().equals(AiCommand.STOP)) {
                onlyStops = false;
                break;
            }
        }
        return onlyStops;
    }
    
    private Collection<MemoryCommand> parseMemoryCommands(String[] commandArguments) {
        
        Collection<MemoryCommand> commands = new ArrayList<>();
        for (int i = 0; i < commandArguments.length; i += NEXT_COMMAND_INCREMENT) {
            
            Optional<AiCommand> command = AiCommand.findByName(commandArguments[i]);
            
            if (command.isEmpty()) {
                return null;
            }
            
            int argumentA;
            int argumentB;
            
            try {
                argumentA = Integer.parseInt(commandArguments[i + FIRST_ARGUMENT_INCREMENT]);
                argumentB = Integer.parseInt(commandArguments[i + SECOND_ARGUMENT_INCREMENT]);
            } catch (NumberFormatException e) {
                return null;
            }
            
            MemoryCommand memoryCommand = new MemoryCommand(command.get(), argumentA, argumentB);
            commands.add(memoryCommand);
        }
        
        return commands;
    }
    
    @Override
    public String getHelpMessage() {
        return HELP_MESSAGE;
    }
    
    @Override
    public Phase getPhase() {
        return this.phase;
    }
}
