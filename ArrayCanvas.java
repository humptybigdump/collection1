package de.paulh.mvc.view.swing;

import javax.swing.*;
import java.awt.*;

public class ArrayCanvas extends JPanel {

    private int[] array;

    public ArrayCanvas() {
        this.array = new int[0];
    }

    public void update(int[] array) {
        this.array = array;
        repaint();
    }

    @Override
    public void paintComponent(Graphics g) {
        g.setColor(Color.LIGHT_GRAY);
        g.fillRect(0, 0, 400, 400);

        g.setColor(Color.BLACK);
        g.drawLine(0, 200, 400, 200);

        g.setColor(Color.RED);
        for (int i = 0; i < array.length; i++) {
            g.fillRect(i * 10 + 10, 200 - array[i], 5, array[i]);
        }
    }
}