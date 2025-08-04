#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>

#ifndef M_PI
#    define M_PI 3.14159265358979323846
#endif

#define ZAHLENTYP float
//#define ZAHLENTYP double


ZAHLENTYP f(ZAHLENTYP x) {
  ZAHLENTYP val=0.0;
  /* Hier funktionsdefinition */
  return val;
//#  return 
}

ZAHLENTYP df(ZAHLENTYP x) {
  ZAHLENTYP val=0.0;
  /* Hier die Funktionsdefinition */
  return val;
} 

ZAHLENTYP Dplus(ZAHLENTYP x0, ZAHLENTYP h){
  ZAHLENTYP val=0.0;
  /* Hier die Funktionsdefinition */
  return val;
}

ZAHLENTYP Dminus(ZAHLENTYP x0, ZAHLENTYP h){
  ZAHLENTYP val=0.0;
  /* Hier die Funktionsdefinition */
  return val;
}

ZAHLENTYP Dzentral(ZAHLENTYP x0, ZAHLENTYP h){
  ZAHLENTYP val=0.0;
  /* Hier die Funktionsdefinition */
  return val;
}

int main() {
  ZAHLENTYP x0 = 1.0;
  ZAHLENTYP h  = 1e-1;

  // TODO Ausgabe des Fehlers von D+,D- und D für unterschiedliche h
  printf("           h\t\t      Fehler D+\t\t  Fehler D-\t     Fehler D\n");
  /* TIPP:
   * Für die Ausgabe der Nachkommastellen nutzen Sie die Formatierungsmöglichkeiten von printf für den ZAHLENTYP
   * Der Datentyp float hat 7 Nachkommastellen und double 16
   * Beispiel: 
   *  float var1=3.1415926;
   *  printf("%.7f\n",var1);  // gibt 7 Nachkommastellen aus
   *  double var2=3.14159265358979323846
   *  printf("%.16lf\n",var1); // gibt 16 Nachkommastellen aus
   */

  return 0;
}
