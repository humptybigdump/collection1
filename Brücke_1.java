
public class Brücke implements Beispiel {
    public void show(){
        Plattform plattform = new WindowsSpielEnginge();
        Spiel spiel = new Tetris(plattform);
        spiel.runn();
    }

    /**
     * Abstraktion
     */
    abstract class Spiel {
        Plattform plattform;
        public Spiel(Plattform plattform){
            this.plattform = plattform;
        }
        void runn() {
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
    interface Plattform{
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
    class WindowsSpielEnginge implements Plattform {
        @Override
        public void render(Spiel spiel) {
            System.out.print("WindowsEngine: ");
            spiel.play();
        }
    }
}
