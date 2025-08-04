package model.files.types;

import model.files.Tag;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Represents a generic file.
 *
 * @author ugmom
 */
public class Document implements Comparable<Document> {
    private static final String UNDEFINED_VALUE = "undefined";
    private static final String EXCEPTION_DEFINED_TAG = "Tag must have an undefined value";

    private final String fileName;
    private final String type;
    private int accessCount;
    private final Map<String, Tag> tags;
    private final List<Tag> undefinedTags = new ArrayList<>();
    /**
     * Constructs a new file.
     *
     * @param fileName is the file name.
     * @param type is the type of file.
     * @param tags are the tags associated to this file.
     * @param accessCount is the amount of times this file was accessed.
     */
    public Document(String fileName, String type, Map<String, Tag> tags, int accessCount) {
        this.fileName = fileName;
        this.type = type;
        this.accessCount = accessCount;
        this.tags = tags;
    }

    /**
     * Constructs a copy of a document.
     *
     * @param document is the copy target.
     */
    public Document(Document document) {
        this.fileName = document.fileName;
        this.type = document.type;
        this.accessCount = document.accessCount;
        this.tags = new HashMap<>(document.tags);
    }

    /**
     * Gets the access count of the file.
     *
     * @return the access count.
     */
    public int getAccessCount() {
        return this.accessCount;
    }

    /**
     * Updates the access count of a file.
     *
     * @param accessCount is the new access count.
     */
    public void setAccessCount(int accessCount) {
        this.accessCount = accessCount;
    }

    /**
     * Gets the file name.
     * @return the file name.
     */
    public String getFileName() {
        return this.fileName;
    }

    /**
     * Gets the tags map.
     *
     * @return the tags map.
     */
    public Map<String, Tag> getTags() {
        return new HashMap<>(this.tags);
    }
    
    /**
     * Adds an undefined tag.
     *
     * @param tag is the undefined tag.
     * @throws IllegalArgumentException if the tag is not undefined.
     */
    public void addUndefinedTag(Tag tag) {
        if (!tag.getTagValue().equals(UNDEFINED_VALUE)) {
            throw new IllegalArgumentException(EXCEPTION_DEFINED_TAG);
        }
        
        this.undefinedTags.add(tag);
    }
    
    /**
     * Gets all undefined tags.
     *
     * @return the undefined tags.
     */
    public List<Tag> getUndefinedTags() {
        return this.undefinedTags;
    }

    /**
     * Checks if this document contains all tags provided.
     *
     * @param tags are the list of tags to check.
     * @return true if all are contained, false otherwise.
     */
    public boolean containsAll(List<Tag> tags) {
        boolean containsAll = true;
        
        for (Tag tag : tags) {
            if (!undefinedTags.contains(tag) && !this.tags.containsValue(tag)) {
                containsAll = false;
                break;
            }
        }
        return containsAll;
    }

    @Override
    public int hashCode() {
        return this.fileName.hashCode();
    }
    @Override
    public boolean equals(Object other) {
        return this == other || other instanceof Document document && fileName.equals(document.fileName)
                && type.equals(document.type) && accessCount == document.accessCount;
    }

    @Override
    public int compareTo(Document o) {
        return fileName.compareTo(o.fileName);
    }
}
