interface A {
  void g();
}
interface B {
  void h();
}
interface C extends A, B {
  void f();
}
class X {
  public void h() {
  }
  public void i() {
  }
}
interface D {
  void i();
}
class Y extends X implements C, D {
  public void f() {
  }
  public void g() {
  }
}

