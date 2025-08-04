import java.awt.*;
public class ColorButton extends Button {
  public ColorButton(Color c) {
    new ColorChanger(c, this).start();
  }
}

