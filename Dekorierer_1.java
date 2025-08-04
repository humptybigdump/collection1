
public class Dekorierer implements Beispiel {
    @Override
    public void show() {

        Essen essen = new Pizza();
        essen = new Kartoffel(essen);
        essen = new Salat(essen);
        essen = new Kartoffel(essen);

        System.out.print("Heute gibt es: ");
        essen.erstelleGericht();
    }

    /**
     * Komponente
     */
    abstract class Essen {
        abstract void erstelleGericht();
    }

    /**
     * Konkrete Komponente
     */
    class Pizza extends Essen {
        @Override
        void erstelleGericht() {
            System.out.println("und als Hauptgang Pizza");
        }
    }

    /**
     * Dekorierer
     */
    abstract class Beilage extends Essen {
        Essen essen;
        public Beilage(Essen essen) {
            this.essen = essen;
        }

        @Override
        void erstelleGericht() {
            dekoriereGericht();
            essen.erstelleGericht();
        }

        abstract void dekoriereGericht();
    }

    /**
     * Konkreter Dekorierer
     */
    class Salat extends Beilage {

        public Salat(Essen essen) {
            super(essen);
        }

        @Override
        void dekoriereGericht() {
            System.out.print("Salat, ");
        }
    }

    /**
     * Konkreter Dekorierer
     */
    class Pommes extends Beilage {

        public Pommes(Essen essen) {
            super(essen);
        }

        @Override
        void dekoriereGericht() {
            System.out.print("Pommes, ");
        }
    }

    /**
     * Konkreter Dekorierer
     */
    class Kartoffel extends Beilage {

        public Kartoffel(Essen essen) {
            super(essen);
        }

        @Override
        void dekoriereGericht() {
            System.out.print("Kartoffel, ");
        }
    }

}
