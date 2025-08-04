package de.paulh.mvc.controller;

import de.paulh.mvc.model.SortingModel;
import de.paulh.mvc.observer.Observer;
import de.paulh.mvc.view.View;

public interface Controller extends Observer {

    void requestFill(String input);

    void requestSort();

    static Controller by(SortingModel model, View view) {
        return new DefaultController(model, view);
    }
}