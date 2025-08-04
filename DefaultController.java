package de.paulh.mvc.controller;

import de.paulh.mvc.model.SortingModel;
import de.paulh.mvc.view.View;

public class DefaultController implements Controller {

    private final SortingModel model;
    private final View view;

    public DefaultController(SortingModel model, View view) {
        this.model = model;
        this.view = view;
    }

    @Override
    public void requestFill(String input) {
        int length = Integer.parseInt(input);
        model.fill(length);
    }

    @Override
    public void requestSort() {
        model.startSortProcess();
    }

    @Override
    public void update() {
        int[] array = model.getArray();
        view.drawArray(array);
    }
}