import java.util.ArrayList;
import java.util.List;

public class Beobachter implements Beispiel {
    @Override
    public void show() {
        LameButton button = new LameButton();
        new ActionListener(button);
        new DontCareListener(button);
        button.pushButton();
        button.pushButton();

    }

    /**
     * Subjekt
     */
    abstract class AbstractButton {
        List<EventListener> listeners = new ArrayList<>();

        void addListener(EventListener a){
            listeners.add(a);
        }

        void notifyListeners(){
            for(EventListener el: listeners){
                el.actionPerformed();
            }
        }
    }

    /**
     * Konkrete Subjekt
     */
    class LameButton extends AbstractButton {
        int counter = 0;
        void pushButton(){
            counter++;
            notifyListeners();
        }
        int getCounter(){
            return counter;
        }
    }

    /**
     * Beobachter
     */
    interface EventListener {
        void actionPerformed();
    }

    /**
     * Konkreter Beobachter
     */
    class ActionListener implements EventListener {
        private final LameButton button;
        ActionListener(LameButton button){
            this.button = button;
            button.addListener(this);
        }

        @Override
        public void actionPerformed() {
            System.out.println("Something changed. New State: " + button.getCounter());
        }
    }

    /**
     * Konkreter Beobachter
     */
    class DontCareListener implements EventListener {
        private LameButton button;
        DontCareListener(LameButton button){
            this.button = button;
            button.addListener(this);
        }
        @Override
        public void actionPerformed() {
            System.out.println("Something changed, but I dont care.");
        }
    }
}
