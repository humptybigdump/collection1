#Importieren von Bibliotheken
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import ternary
from scipy.optimize import fsolve

import Gleichungen as g

#Molenbruch Ausgangsgemisch
x1_0 = 0.2      #Anfangsmolenbruch von Komponente x1
x2_0 = 0.55     #Anfangsmolenbruch von Komponente x2
x3_0 = 0.25     #Anfangsmolenbruch von Komponente x3

#Trennfaktoren Ausgangsgemisch
w21 = 0.4       #Trennfaktor des Ausgangsgemisches der Komponenten x2 und x1
w31 = 0.2       #Trennfaktor des Ausgangsgemisches der Komponenten x3 und x1

#Werte Tabellen erstellen
n = 11 #Anzahl der Werte
N_N0 = np.linspace(1, 0, n)
WerteX1 = np.zeros(n)
WerteX2 = np.zeros(n)
WerteX3 = np.zeros(n)
WerteY1 = np.zeros(n)
WerteY2 = np.zeros(n)
WerteY3 = np.zeros(n)

#0 aus dem N_N0 array löschen, da es für 0 keine Lösung gibt, Faktor 5 kleiner als die Schrittweite als "nahe 0"
N_N0[n-1] = 1 / (n-1) / 5
#print(N_N0)

#Schleife um Wertetabelle zu füllen
for x in range(n):
    ## Rückstandszusammensetzung
    #x1 mittels Solver und Gl. 10 berechnen
    WerteX1[x] = fsolve(g.gleichung10_minus1, 0.00001, (x1_0, x2_0, x3_0, N_N0[x], w21, w31))
    #x2 und x3 mit Gl. 9 berechnen
    WerteX2[x] = g.gleichung9(WerteX1[x], x1_0, x2_0, N_N0[x], w21)
    WerteX3[x] = g.gleichung9(WerteX1[x], x1_0, x3_0, N_N0[x], w31)
    
    ## Produktzusammensetzung
    #y1 mit Gl. 17 bercehnen
    WerteY1[x] = g.gleichung17(WerteX1[x], WerteX2[x], WerteX3[x], w21, w31)
    #y2 und y3 mit Gl. 16 berechnen
    WerteY2[x] = g.gleichung16(WerteY1[x], WerteX1[x], WerteX2[x], w21)
    WerteY3[x] = g.gleichung16(WerteY1[x], WerteX1[x], WerteX3[x], w31)

## Rückstandszusammensetzung darstellen
fig, ax = plt.subplots(figsize=(6, 4))
ax.plot(N_N0, WerteX1, label=r'$\tilde{x}_{1}$', marker="o")
ax.plot(N_N0, WerteX2, label=r'$\tilde{x}_{2}$', marker="o")
ax.plot(N_N0, WerteX3, label=r'$\tilde{x}_{3}$', marker="o")
ax.set_xlim([1, 0])
ax.set_ylim([0, 1])
ax.legend()
ax.set_title("Rückstandszusammensetzung")
ax.set_xlabel(r'$\longleftarrow \: N^{L} / N_{0}^{L} \: [-]$')
ax.set_ylabel(r'$\tilde{x} \: [-] \: \longrightarrow$')
ax.grid()
plt.savefig("Rückstandszusammensetzung.svg", bbox_inches="tight")
plt.show()

## Rückstand im ternären Diagram darstellen
points = []
for i in range(n):
    points.append((WerteX3[i],WerteX1[i],WerteX2[i]))
matplotlib.rcParams['figure.figsize'] = (10, 10)
fig, tax = ternary.figure(scale=1.0)
tax.plot(points, linewidth=2.0)
fontsize = 14
offset = 0.1
tax.right_corner_label(r'$\tilde{x}_{3} \: [-]$', fontsize=fontsize)
tax.top_corner_label(r'$\tilde{x}_{1} \: [-]$', fontsize=fontsize)
tax.left_corner_label(r'$\tilde{x}_{2} \: [-]$', fontsize=fontsize)
tax.left_axis_label(r'$\longleftarrow \: \tilde{x}_{2} \: [-]$', fontsize=fontsize, offset=offset)
tax.right_axis_label(r'$\longleftarrow \: \tilde{x}_{1} \: [-]$', fontsize=fontsize, offset=offset)
tax.bottom_axis_label(r'$\tilde{x}_{3} \: [-] \: \longrightarrow$', fontsize=fontsize, offset=offset)
tax.get_axes().axis('off')
tax.clear_matplotlib_ticks()
tax.ticks(axis='lbr', linewidth=1, multiple=0.1, tick_formats="%.1f")
tax.boundary()
tax.gridlines(multiple=0.1, color="black")
tax.savefig("Ternäres Diagramm.svg", bbox_inches="tight")
tax.show()

## Produktzusammensetzung darstellen
fig, ax = plt.subplots(figsize=(6, 4))
ax.plot(N_N0, WerteY1, label=r'$\tilde{y}_{1}$', marker="o")
ax.plot(N_N0, WerteY2, label=r'$\tilde{y}_{2}$', marker="o")
ax.plot(N_N0, WerteY3, label=r'$\tilde{y}_{3}$', marker="o")
ax.set_xlim([1, 0])
ax.set_ylim([0, 1])
ax.legend()
ax.set_title("Produktzusammensetzung")
ax.set_xlabel(r'$\longleftarrow \: N^{L} / N_{0}^{L} \: [-]$')
ax.set_ylabel(r'$\tilde{y} \: [-] \: \longrightarrow$')
ax.grid()
plt.savefig("Produktzusammensetzung.svg", bbox_inches="tight")
plt.show()

## Werte nach Excel-Exportieren, um sie evtl. in Origin zu verwenden
df_Ergebnise = pd.DataFrame(data=WerteX1, columns=["X1"])
df_Ergebnise["X2"] = WerteX2
df_Ergebnise["X3"] = WerteX3
df_Ergebnise["Y1"] = WerteY1
df_Ergebnise["Y2"] = WerteY2
df_Ergebnise["Y3"] = WerteY3
df_Ergebnise["N/N0"] = N_N0
df_Ergebnise.to_excel("Ergebnisse Übung 0.xlsx")
print(df_Ergebnise)
