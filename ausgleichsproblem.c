#include <stdio.h>
#include <stdlib.h>
/*********************************************************************/
/*                                                                   */
/* Es liegen Messdaten "input.dat" in Form von Wertepaaren vor.      */
/* Durch diese Punkte muss eine Ausgleichskurve gelegt werden.       */
/*                                                                   */ 
/*********************************************************************/
/*             Zu Beginn einige Hilfsfunktionen                      */
// --------------------------------------------------------------------
// Funktion um die Wertepaare abzuzählen


/*

md5sum input.dat
1f109499c3d87ecde1fd8eb531a55874

------- AT*T -----
9.322101e+01 3.226500e+00
3.226500e+00 3.852723e-01
------- AT*y -----
4.481573e+00
5.242451e-01
------- Ainv -----
1.510565e-02 -1.265037e-01
-1.265037e-01 3.654985e+00
------- lambda -----
lambda1: 1.378118e-03 
lambda2: 1.349172e+00 

 */

int getNumberofPoints(char *name) {
  FILE   *fp;
  char   *line = NULL;
  int cnt = 0;
  size_t  len = 0;

  if ((fp = fopen(name, "r")) == NULL) {
    exit(EXIT_FAILURE);
  }
  while (getline(&line, &len, fp) != -1) {
    cnt++;
  }
  free(line);

  return cnt;
}
// In dieser Funktion werden die Wertepaare eingelesen und 
// in Form von Arrays x[N] und y[N] übergeben.
void readFile(char *name, double x[], double y[]) {
  FILE   *fp;
  char   *line = NULL;
  size_t  len = 0;

  if ((fp = fopen(name, "r")) == NULL) {
    exit(EXIT_FAILURE);
  }

  int cnt = 0;
  while (getline(&line, &len, fp) != -1) {
    sscanf(line, "%lf %lf", &x[cnt], &y[cnt]);
    cnt++;
  }

  free(line);
}
// --------------------------------------------------------------------
// --------------------------------------------------------------------

// Definition der Ansatzfunktionen f1 und f2


int main(int argc, char* argv[]){
  // Abzählen der Wertepaare
  int N = getNumberofPoints("input.dat");

  double x[N]; //Vektor für den Abstand der Messung
  double y[N]; //Vektor für den gemessenen Wert
  //   Einlesen der Daten  
  readFile("input.dat", x, y);
  
  double lambda1 = 0.0;  // Koeffizient für die Funktion f1
  double lambda2 = 0.0;  // Koeffizient für die Funktion f2
  
//_____________________________________________________________________
// benötigte Variablen einlegen und initialisieren.
                                                               
//   Berechnung von lambda1                                    


  // Plotten wenn plotflag!=0
  long plotflag = 0;
  

  if (plotflag) {
    FILE *gp = popen("gnuplot -p","w");
    fprintf(gp,"reset; set key right top box; set xrange [0.0:100]; set xlabel \"x\";\n"
        "set yrange [-0.0:0.75]; set ylabel \"y\";\n"
        " f(x) = %le*x*(1+x)**(-1)+%le*(2+x)**(-1);\n "
        " plot f(x) lt -1 lw 2, \"input.dat\" using 1:2 pt 7 title 'measured data';\n" //lt: LineType, lw: Linewidth, using 1:2: zweite spalte verwenden
      ,lambda1,lambda2);
    pclose(gp);
  }
  
  return 0;
}
