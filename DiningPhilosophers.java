
import javax.swing.*;
import java.net.URL;
import java.awt.Color;
import java.awt.Dimension;

// for dealing with the start stop button
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

// for dealing with the delay slider
import javax.swing.event.ChangeListener;
import javax.swing.event.ChangeEvent;

import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;

public class DiningPhilosophers extends javax.swing.JApplet
			  implements ActionListener, ChangeListener {

    private JButton stopStartButton = new JButton("start");

    // delays can go from 0 to 10,000 milliseconds, initial value is 500
    int grabDelay = 500;
    private JSlider grabDelaySlider = new JSlider(JSlider.HORIZONTAL, 0, 100, 5);
    private JLabel label = new JLabel("  500 milliseconds");
    private JPanel philosopherArea;

    public ImageIcon[] imgs = new ImageIcon[3];
    Chopstick[] chopsticks = new Chopstick[NUMPHILS];
    String[] names = { "Arisduktle" ,
		       "Dukrates",
		       "Pythagoduke",
		       "Duko",
		       "Dukimedes" };

    static final int NUMPHILS = 5;

    static final int HUNGRYDUKE = 0;
    static final int RIGHTSPOONDUKE = 1;
    static final int BOTHSPOONSDUKE = 2;

    private int width = 0;
    private int height = 0;
    private double spacing;
    private static final double MARGIN = 10.0f;

    private Philosopher[] philosophers = new Philosopher[NUMPHILS];

    public void init() {

        imgs[HUNGRYDUKE] = new ImageIcon(getURL("images/hungryduke.gif"));
        imgs[RIGHTSPOONDUKE] = new ImageIcon(getURL("images/rightspoonduke.gif"));
        imgs[BOTHSPOONSDUKE] = new ImageIcon(getURL("images/bothspoonsduke.gif"));

        width = imgs[HUNGRYDUKE].getIconWidth() + (int)(MARGIN*2.0);
        height = imgs[HUNGRYDUKE].getIconHeight() + (int)(MARGIN*2.0);
        spacing = width + MARGIN;

        GridBagLayout gridBag = new GridBagLayout();
        GridBagConstraints c = new GridBagConstraints();

        JPanel contentPane = new JPanel();
        contentPane.setLayout(gridBag);

        philosopherArea = new JPanel(null);
        philosopherArea.setBackground(Color.white);
        Dimension preferredSize = createPhilosophersAndChopsticks();
        philosopherArea.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createLoweredBevelBorder(),
                        BorderFactory.createEmptyBorder(5, 5, 5, 5)
        ));
        philosopherArea.setPreferredSize(preferredSize);

        c.fill = GridBagConstraints.BOTH;
        c.weighty = 1.0;
        c.gridwidth = GridBagConstraints.REMAINDER; //end row
        gridBag.setConstraints(philosopherArea, c);
        contentPane.add(philosopherArea);

        c.fill = GridBagConstraints.HORIZONTAL;
        c.weightx = 1.0;
        c.weighty = 0.0;
        gridBag.setConstraints(stopStartButton, c);
        contentPane.add(stopStartButton);

        c.gridwidth = GridBagConstraints.RELATIVE; //don't end row
        c.weightx = 1.0;
        c.weighty = 0.0;
        gridBag.setConstraints(grabDelaySlider, c);
        contentPane.add(grabDelaySlider);

        c.weightx = 0.0;
        c.gridwidth = GridBagConstraints.REMAINDER; //end row
        gridBag.setConstraints(label, c);
        contentPane.add(label);
        contentPane.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
        setContentPane(contentPane);

	stopStartButton.addActionListener(this);
	grabDelaySlider.addChangeListener(this);

    }

    public void actionPerformed(ActionEvent e) {
        if (stopStartButton.getText().equals("stop/reset")) {
            stopPhilosophers();
            stopStartButton.setText("start");
        } else if (stopStartButton.getText().equals("start")) {
            startPhilosophers();
            stopStartButton.setText("stop/reset");
        }
    }

    public void stateChanged(ChangeEvent e) {
        JSlider source = (JSlider)e.getSource();
        grabDelay = source.getValue()*100;
        label.setText(String.valueOf(grabDelay + " milliseconds"));
    }

    public void startPhilosophers() {
        for (int i = 0; i < NUMPHILS; i++)
            philosophers[i].philThread.start();
    }

    public void stopPhilosophers() {
        for (int i = 0; i < NUMPHILS; i++)
            philosophers[i].philThread.interrupt();
    }

    public Dimension createPhilosophersAndChopsticks() {
        double x, y;
        double radius = 80.0;
        double centerAdj = 85.0;
        double radians;

        Dimension preferredSize = new Dimension(0, 0);

/* for a straight line
        y = MARGIN;
*/
        for (int i = 0; i < NUMPHILS; i++)
            chopsticks[i] = new Chopstick();

        for (int i = 0; i < NUMPHILS; i++) {
/* for a straight line
            x = i * spacing;
*/
            radians = i*(2.0 * Math.PI /(double)NUMPHILS);
            x = Math.sin(radians) * radius + centerAdj; 
            y = Math.cos(radians) * radius + centerAdj; 
            philosophers[i] = new Philosopher(this, i, imgs[HUNGRYDUKE]);
            philosophers[i].setBounds((int)x, (int)y, width, height);
            philosopherArea.add(philosophers[i]);
            if ((int)x > preferredSize.width)
		preferredSize.width = (int)x;
            if ((int)y > preferredSize.height)
		preferredSize.height = (int)y;
        }

        preferredSize.width += width;
        preferredSize.height += height;
        return preferredSize;
    }

    protected URL getURL(String filename) {
        URL codeBase = getCodeBase();
        URL url = null;

        try {
            url = new URL(codeBase, filename);
        } catch (java.net.MalformedURLException e) {
            System.out.println("Couldn't create image: "
                             + "badly specified URL");
            return null;
        }

        return url;
    }
}
