package Model;

import javax.swing.*;
import java.util.ArrayList;
import java.util.List;

// Speichert alle Tasks, die fertig sind
public class DoneList extends AbstractListModel<Task> {
    private List<Task> done;

    public DoneList() {
        done = new ArrayList<>();
    }

    public void addTask(Task task) {
        done.add(task);
    }

    public List<Task> getTasks() {
        return this.done;
    }

    public void addTasks(List<Task> tasks) {
        this.done.addAll(tasks);
    }

    @Override
    public int getSize() {
        return done.size();
    }

    @Override
    public Task getElementAt(int index) {
        return done.get(index);
    }
}
