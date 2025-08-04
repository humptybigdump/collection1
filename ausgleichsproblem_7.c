#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/*********************************************************************/
/*                                                                   */
/* Es liegen Messdaten "input.dat" in Form von Wertepaaren vor.      */
/* Durch diese Punkte muss eine Ausgleichskurve gelegt werden.       */
/*                                                                   */ 
/*********************************************************************/
/*             Zu Beginn einige Hilfsfunktionen                      */
// --------------------------------------------------------------------


/*
------- AT*A ---------
2.500000e+01 3.000000e+02
3.000000e+02 4.900000e+03
------- AT*logI -----
8.282651e+01
1.223997e+03
------- ATAinv ------
1.507692e-01 -9.230769e-03
-9.230769e-03 7.692308e-04
------- lambda -----
ln_a: 1.189257e+00
b:    1.769836e-01
*/

/** @brief Funktion um die Wertepaare abzuzählen.
 */
int getNumberofPoints(char *name) {
  FILE   *fp;
  char   *line = NULL;
  size_t  len = 0;

  if ((fp = fopen(name, "r")) == NULL) {
    exit(EXIT_FAILURE);
  }

  int cnt = 0;
  while (getline(&line, &len, fp) != -1) {
    cnt++;
  }

  free(line);
  fclose(fp);

  return cnt;
}
/** @brief In dieser Funktion werden die Wertepaare eingelesen und in Form von Arrays t[N] und I[N] übergeben.
 */
void readFile(char *name, int t[], double I[]) {
  FILE   *fp;
  char   *line = NULL;
  size_t  len = 0;

  if ((fp = fopen(name, "r")) == NULL) {
    exit(EXIT_FAILURE);
  }

  int cnt = 0;
  while (getline(&line, &len, fp) != -1) {
    sscanf(line, "%i %lf", &t[cnt], &I[cnt]);
    cnt++;
  }

  free(line);
  fclose(fp);
}

// --------------------------------------------------------------------
// --------------------------------------------------------------------

int main(int argc, char* argv[]){
  // Abzaehlen der Wertepaare
  int N = getNumberofPoints("input.dat");

  int    t[N]; //Vektor für den Kalenderwoche der Messung
  double I[N]; //Vektor für den gemessenen Inzidenzwerte
  // Einlesen der Daten
  readFile("input.dat", t, I);

  // Hilsvariabelen fuer t_0 und Logarithmen von I
  int t_0 = t[0];

  double logI[N];

//_____________________________________________________________________
// Berechnung der Matrix A^T*A und der rechten Seiten A^T*y
  double ATA[2][2] = {{0.0, 0.0},
                      {0.0, 0.0}};
  double ATlogI[2] = {0.0, 0.0};


  // Invertierung von ATA (wegen kleiner Groesse)

  // Ermittlung von ln(a) und b aus ATA^{-1} und ATy


  // Bestimmung von a selbst
  double a = exp(ln_a);

  // Plotten wenn plotflag!=0
  long plotflag = 0;

  if (plotflag) {
    FILE *gp = popen("gnuplot -p","w");
    fprintf(gp,"reset; set key left top box; set xlabel \"t - t_0\";\n"
        "set ylabel \"y\";\n"
        "set autoscale fix\n"
//         "set logscale xy\n"
        " f(t) = %le*exp(%le*(t - 23));\n "
        " plot f(x) lt -1 lw 2, \"input.dat\" using 1:2 pt 7 title 'measured data';\n", //lt: LineType, lw: Linewidth, using 1:2: zweite spalte verwenden
        a, b);
    pclose(gp);
  }
  
  return 0;
}
