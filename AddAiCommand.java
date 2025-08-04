package codefight.command;

import codefight.model.CodeFight;
import codefight.model.game.Phase;
import codefight.model.player.Player;
import codefight.model.memory.AiCommand;
import codefight.model.memory.MemoryCommand;

import java.util.ArrayList;
import java.util.List;

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
    private static final String ERROR_INCOMPLETE_LIST = "the list of commands is malformed!";
    private static final String ERROR_AI_COMMAND_NOT_FOUND = "command '%s' does not exist";
    private static final String ERROR_DUPLICATE_PLAYER_NAME = "'%s' is already being used";
    private static final String ERROR_ONLY_STOPS = "'%s' only has STOP commands";
    private static final String ERROR_NUMERICAL_VALUES_ONLY = "command '%s' must have numerical values, but has '%s' and '%s'";
    
    private static final String HELP_MESSAGE = "Adds an AI";
    
    @Override
    public CommandResult execute(CodeFight model, String[] commandArguments) {

        String[] commandLine = commandArguments[AI_COMMANDS].trim().split(REGEX_COMMAND_SEPARATOR);
        if (commandLine.length % REQUIRED_COMMAND_LENGTH != 0) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_INCOMPLETE_LIST);
        }
        
        List<MemoryCommand> commands = new ArrayList<>();
        CommandResult commandParsingResult = parseMemoryCommands(commandLine, commands);
        String aiName = commandArguments[AI_NAME_INDEX];
        
        if (commandParsingResult != null) {
            return commandParsingResult;
        } else if (onlyStopCommands(commands)) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_ONLY_STOPS.formatted(aiName));
        }

        Player player = new Player(aiName, commands);

        if (commands.size() - 1 > model.getMemoryLength() / MIN_PLAYERS) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_OVERLAP);
        }

        if (model.playerExists(player)) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_DUPLICATE_PLAYER_NAME.formatted(aiName));
        }
        model.executePlayerRequest((handler) -> handler.addPlayer(player));
        return new CommandResult(CommandResultType.SUCCESS, aiName);
    }
    
    private boolean onlyStopCommands(List<MemoryCommand> commands) {
        return commands.stream().allMatch(m -> m.getAiCommand().equals(AiCommand.STOP));
    }
    
    private CommandResult parseMemoryCommands(String[] commandArguments, List<MemoryCommand> commands) {
        for (int i = 0; i < commandArguments.length; i += NEXT_COMMAND_INCREMENT) {
            AiCommand command = AiCommand.findByName(commandArguments[i]);
            if (command == null) {
                return new CommandResult(CommandResultType.FAILURE, ERROR_AI_COMMAND_NOT_FOUND.formatted(commandArguments[i]));
            }
            int argumentA;
            int argumentB;
            try {
                argumentA = Integer.parseInt(commandArguments[i + FIRST_ARGUMENT_INCREMENT]);
                argumentB = Integer.parseInt(commandArguments[i + SECOND_ARGUMENT_INCREMENT]);
            } catch (NumberFormatException e) {
                return new CommandResult(CommandResultType.FAILURE,
                        ERROR_NUMERICAL_VALUES_ONLY.formatted(
                                commandArguments[i],
                                commandArguments[i + FIRST_ARGUMENT_INCREMENT],
                                commandArguments[i + SECOND_ARGUMENT_INCREMENT]));
            }
            MemoryCommand memoryCommand = new MemoryCommand(command, argumentA, argumentB);
            commands.add(memoryCommand);
        }
        return null;
    }
    
    @Override
    public String getHelpMessage() {
        return HELP_MESSAGE;
    }
    
    @Override
    public Phase getPhase() {
        return Phase.INIT_PHASE;
    }

    @Override
    public int requiredArguments() {
        return REQUIRED_ARGS_LENGTH;
    }
}
