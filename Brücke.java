/**
 * Beispiel Brücke
 * @author Nicolai Hüning
 * @version 1.0
 */
public class Brücke implements Beispiel {
    public void show(){
        Plattform plattform = new LinuxSpielEngine();
        Spiel spiel = new Schach(plattform);

        spiel.run();
        spiel.setPlattform(new WindowsSpielEngine());
        spiel.run();
    }

    /**
     * Abstraktion
     */
    abstract class Spiel {
        private Plattform plattform;
        public Spiel(Plattform plattform){
            this.plattform = plattform;
        }
        void run() {
            plattform.render(this);
        }
        abstract void play();

        void setPlattform(Plattform plattform){
            this.plattform = plattform;
        }
    }

    /**
     * Spezialisierte Abstraktion
     */
    class Tetris extends Spiel {
        public Tetris(Plattform plattform) {
            super(plattform);
        }
        @Override
        void play(){
            System.out.println("Spiele Tetris");
        }
    }

    /**
     * Spezialisierte Abstraktion
     */
    class Schach extends Spiel {
        public Schach(Plattform plattform) {
            super(plattform);
        }
        @Override
        void play(){
            System.out.println("Spiele Schach");
        }
    }

    /**
     * Spezialisierte Abstraktion
     */
    class Solitaire extends Spiel {
        public Solitaire(Plattform plattform) {
            super(plattform);
        }
        @Override
        void play() {
            System.out.println("Spiele Solitaire");
        }
    }

    /**
     * Implementierer
     */
    interface Plattform {
        void render(Spiel spiel);
    }

    /**
     * Konkreter Implemenierer
     */
    class LinuxSpielEngine implements Plattform {
        @Override
        public void render(Spiel spiel) {
            System.out.print("LinuxEngine: ");
            spiel.play();
        }
    }

    /**
     * Konkreter Implemenierer
     */
    class WindowsSpielEngine implements Plattform {
        @Override
        public void render(Spiel spiel) {
            System.out.print("WindowsEngine: ");
            spiel.play();
        }
    }
}
