package model.files.types;

import model.files.Tag;

import java.util.Map;

/**
 * Represents an audio file.
 *
 * @author ugmom
 */
public class Audio extends Document {
    private static final String LENGTH_TAG_NAME = "length";
    private static final String AUDIO_LENGTH_TAG = "audiolength";
    private static final String SAMPLE_TAG_VALUE = "sample";
    private static final String NORMAL_TAG_VALUE = "normal";
    private static final String SHORT_TAG_VALUE = "short";
    private static final String LONG_TAG_VALUE = "long";
    private static final int SAMPLE_CONDITION = 10;
    private static final int SHORT_CONDITION = 60;
    private static final int NORMAL_CONDITION = 300;

    /**
     * Constructs a new audio file.
     *
     * @param fileName is the file name.
     * @param type is the type of file.
     * @param tags are the tags associated to this file.
     * @param length is the length of the file.
     * @param accessCount is the amount of times this file was accessed.
     */
    public Audio(String fileName, String type, Map<String, Tag> tags, Integer length, int accessCount) {
        super(fileName, type, tags, accessCount);

        if (length != null && tags.containsKey(LENGTH_TAG_NAME)) {
            if (length < SAMPLE_CONDITION) {
                tags.put(AUDIO_LENGTH_TAG, new Tag(AUDIO_LENGTH_TAG, SAMPLE_TAG_VALUE));
            } else if (length < SHORT_CONDITION) {
                tags.put(AUDIO_LENGTH_TAG, new Tag(AUDIO_LENGTH_TAG, SHORT_TAG_VALUE));
            } else if (length < NORMAL_CONDITION) {
                tags.put(AUDIO_LENGTH_TAG, new Tag(AUDIO_LENGTH_TAG, NORMAL_TAG_VALUE));
            } else {
                tags.put(AUDIO_LENGTH_TAG, new Tag(AUDIO_LENGTH_TAG, LONG_TAG_VALUE));
            }
            tags.remove(LENGTH_TAG_NAME);
        }
    }

}
