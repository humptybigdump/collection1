

public class Berechne {
  public static double compute (String f,
                                double x) throws EvaluationException {
    if (f.equals("sin")) {
      return Math.sin(x);
    }
    else if (f.equals("sqrt")) {
      if (x >= 0)
        return Math.sqrt(x);
      else
        throw new RootException ("Unerlaubtes Argument für SQRT");
    }
    else
      throw new EvaluationException ("Unerlaubte Funktion: " + f);   
  }

  public static void main (String[] args) {
    String f = args[0]; 
    try {
      double x = Double.parseDouble(args[1]);
      System.out.println(compute(f,x));
    }
    catch (RootException re) {
      System.out.println("Probleme beim Wurzelziehen!");
      System.out.println(re);
    }
    catch (EvaluationException ee) {
      System.out.println(ee);
    }
    catch (NumberFormatException nfe) {
      System.out.println("Funktions-Argument kein double-Wert");
    }
    catch (ArrayIndexOutOfBoundsException ae) {
      System.out.println("Aufruf: Berechne <f> <x>");
    }
  }
}


class EvaluationException extends Exception {
 EvaluationException (String info) { 
    super(info); // speichere info im erzeugten Ausnahme-Objekt
  } 
}

class RootException extends EvaluationException {
  RootException (String info) { 
    super(info); // speichere info im erzeugten Ausnahme-Objekt
  } 
}

