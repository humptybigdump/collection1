class Eins {  
  int a, b = 10;  
  Eins() {    a = b; b = 2;  }
}

class Zwei extends Eins {  
  int c = b;
}

class Drei {  
  public static void main (String[] args) {
    Zwei two = new Zwei();
    System.out.println(two.a);
    System.out.println(two.b);
    System.out.println(two.c);
  }
}
