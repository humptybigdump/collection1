package de.paulh.mvc.view.console;

import de.paulh.mvc.controller.Controller;
import de.paulh.mvc.view.View;

import java.util.Arrays;
import java.util.Scanner;

public class ConsoleView implements View {

    @Override
    public void initialize(Controller controller) {
        try (Scanner scanner = new Scanner(System.in)) {
            System.out.println("Hey, please enter the the length of the array:");
            controller.requestFill(scanner.nextLine());

            System.out.println("Enter to sort the array.");
            scanner.nextLine();
            controller.requestSort();
        }
    }

    @Override
    public void showUp() {
        // Console is always on top
    }

    @Override
    public void drawArray(int[] array) {
        System.out.println(Arrays.toString(array));
    }
}