package flyweight;

import java.awt.*;
import java.util.HashMap;
import java.util.Map;

public class ColorFactory {

    private final Map<Integer, Color> colors;

    public ColorFactory() {
        this.colors = new HashMap<>();
    }

    public Color getColor(int rgb) {
        if (colors.containsKey(rgb)) {
            return colors.get(rgb);
        } else {
            Color color = new Color(rgb, false);
            colors.put(rgb, color);
            return color;
        }
    }
}