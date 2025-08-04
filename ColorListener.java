import java.awt.event.*;
import java.awt.*;
import javax.swing.*;

class ColorListener implements ItemListener {
  private Component comp;
  ColorListener(Component comp) {
    this.comp = comp;
  }
  public void itemStateChanged(ItemEvent e) {
    JComboBox<?> cb = (JComboBox<?>) e.getSource();
    int index = cb.getSelectedIndex();
    switch (index) {
      case 0: comp.setBackground(Color.BLUE); break;
      case 1: comp.setBackground(Color.YELLOW); break;
      case 2: comp.setBackground(Color.RED); break;
      case 3: comp.setBackground(Color.GRAY);
    }
  }
}
