package latin;
import greek.*;
class Delta extends Alpha {
  void accessMethod(Alpha a, Delta d) {
    a.iAmProtected = 10;   // unzulässig, da a in
                           // anderem Package
    d.iAmProtected = 10;   // zulässig, da d der
                           // Klasse Delta angehört
    iAmProtected = 10;     // zulässig wegen Vererbung
    a.protectedMethod();   // unzulässig
    d.protectedMethod();   // zulässig
    protectedMethod();     // zulässig wegen Vererbung
  }
}

