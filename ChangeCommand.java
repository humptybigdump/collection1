package command;

import model.SussySorter;
import model.files.types.Document;

import java.util.List;

/**
 * Represents the "change" command.
 *
 * @author ugmom
 */
final class ChangeCommand implements Command {

    private static final int DIRECTORY_ID_INDEX = 0;
    private static final int FILE_NAME_INDEX = 1;
    private static final int ACCESS_COUNT_INDEX = 2;
    private static final int REQUIRED_ARGUMENTS = 3;

    private static final String ERROR_WRONG_ARGUMENTS = "Wrong amount of arguments (required: %d)";
    private static final String ERROR_INVALID_ARGUMENT = "Invalid arguments (%s, %s)";
    private static final String ERROR_UNASSOCIATED_FILE = "There is no file associated with ID %d";
    private static final String ERROR_FILE_DOES_NOT_EXIST = "File '%s' does not exist";
    private static final String OUTPUT_FORMAT = "Change %d to %d for %s";
    private static final String ERROR_ALL_ZEROS = "Invalid request, access counts would all be zeros";
    private static final String ERROR_NEGATIVE_ACCESS_COUNT = "Negative access counts are not allowed";
    @Override
    public CommandResult execute(SussySorter model, String[] commandArguments) {
        
        if (commandArguments.length != REQUIRED_ARGUMENTS) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_WRONG_ARGUMENTS.formatted(REQUIRED_ARGUMENTS));
        }
        
        int target = 0;
        int newAccessCount = 0;
        String fileName = commandArguments[FILE_NAME_INDEX];
        try {
            target = Integer.parseInt(commandArguments[DIRECTORY_ID_INDEX]);
            newAccessCount = Integer.parseInt(commandArguments[ACCESS_COUNT_INDEX]);
        } catch (NumberFormatException e) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_INVALID_ARGUMENT.formatted(target, newAccessCount));
        }
        if (newAccessCount < 0) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_NEGATIVE_ACCESS_COUNT);
        }


        List<Document> documents = model.getDocuments(target);
        if (documents == null) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_UNASSOCIATED_FILE.formatted(target));
        }

        int oldAccessCount = changeFile(documents, fileName, newAccessCount);
        if (oldAccessCount < 0) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_FILE_DOES_NOT_EXIST.formatted(fileName));
        }

        if (allZeros(documents)) {
            return new CommandResult(CommandResultType.FAILURE, ERROR_ALL_ZEROS);
        }

        model.replace(documents, newAccessCount);
        return new CommandResult(CommandResultType.SUCCESS, OUTPUT_FORMAT.formatted(oldAccessCount, newAccessCount, fileName));
    }

    private boolean allZeros(List<Document> documents) {
        for (Document document : documents) {
            if (document.getAccessCount() != 0) {
                return false;
            }
        }
        return true;
    }

    private int changeFile(List<Document> documents, String fileName, int newAccessCount) {
 
        for (Document document : documents) {
            if (document.getFileName().equals(fileName)) {
                int oldId = document.getAccessCount();
                document.setAccessCount(newAccessCount);
                return oldId;
            }
        }
        return -1;
    }

}
