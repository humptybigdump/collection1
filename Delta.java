package latin;
import greek.*;
class Delta extends Alpha {
  void accessMethod(Alpha a, Delta d) {
    a.iAmProtected = 10;   // unzul�ssig, da a in
                           // anderem Package
    d.iAmProtected = 10;   // zul�ssig, da d der
                           // Klasse Delta angeh�rt
    iAmProtected = 10;     // zul�ssig wegen Vererbung
    a.protectedMethod();   // unzul�ssig
    d.protectedMethod();   // zul�ssig
    protectedMethod();     // zul�ssig wegen Vererbung
  }
}

