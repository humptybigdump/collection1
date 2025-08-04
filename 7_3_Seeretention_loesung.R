## Speicher mit iterativem Differenzenverfahren
# j.wienhoefer@kit.edu

# feste Werte
A <- 3   # Auslass [m²]
mueh <- 0.5 # Formbeiwert
g <- 9.81 # Erdbeschleunigung [m/s²]
delta_t <- 3600   # Zeitschritt [s] - um von m³/s aufs Volumen pro h zu kommen

delta_it <- 0.1   # Kriterium für Iteration

# 1 Schritt: stationär: Qab = Qzu
Q.ab.start <- Q.zu.start <- 5

# Hoehe und Speicher für ersten Schritt ausrechnen
h.start <-  (Q.ab.start /( mueh * A)) ^2 / (2*g)  # m
S.start <- (h.start / 0.018)^2                  # m³

# Objekt 'speicher' mit Spalten fuer alle Groessen erstellen
# Zeit und Zuflussreihe eingeben
# Rest mit Startwerten auffuellen
speicher <- data.frame(Zeit = 1:12,
                       Q.zu = c(5, 15, 25, 30, 23, 17, 
                                12, 8, 7, 6, 5, 5 ) ,
                       Q.ab = Q.ab.start,
                       h = h.start,
                       S = S.start
                       )
                       ## Auch moeglich: 
                       #speicher$h <- h.start
                       ## etc.

# Schleife ueber alle (weiteren) Zeitschritte jj
for( jj in 2:12)
{ 
                                      # Q.ab(ti) = Q.ab(ti-1)
  Q.ab.neu1  <- speicher$Q.ab[jj-1]   # Zwischenspeicher fuer iterierten Abfluss
  
   conv <- delta_it + 1             # Konvergenz jeweils initialisieren
  
  # Schleife zur Iteration, laeuft bis Kriterium unterschritten ist
  while(conv > delta_it)          
  {
    #Anwenden der Speichergleichung (delta_t in [s]!)
    speicher$S[jj] <- (speicher$Q.zu[jj] + speicher$Q.zu[jj-1] - 
                       (Q.ab.neu1 + speicher$Q.ab[jj-1]) 
                       )/2  *  delta_t + speicher$S[jj-1]
    # Speicher -> Hoehe
    speicher$h[jj] <- 0.018 * sqrt(speicher$S[jj])
    
    # Berechnung von Q.ab
    speicher$Q.ab[jj] <- mueh * A * sqrt(2*g) * sqrt(speicher$h[jj])
  
    # Konvergenz: neuen und alten Wert vergleichen
    conv <- abs(speicher$Q.ab[jj] - Q.ab.neu1)/speicher$Q.ab[jj]
  
    Q.ab.neu1 <- speicher$Q.ab[jj]    # Zwischenspeichern
  
    # print(c(conv, Q.ab.neu1))       # bei Bedarf auskommentieren, zeigt Zwischenschritt
  }

}
#######

# PLotten
x11()                            # neues Fenster
layout(1:3)                      # drei Unterfenster
plot(h~Zeit, speicher, t="l")    # Plot 1 Wasserstand
plot(S~Zeit, speicher, t="l")    # Plot 2 Speicherinhalt

# Plot 3: Zu- und Abfluss
with(speicher, matplot(Zeit, cbind(Q.ab, Q.zu), t="l", col=3:4, ylab="Fluss [m³/s]"))
legend("topright", c("Abfluss", "Zufluss"), col = 3:4, lty=1:2, bty="n")

####################
# Unterschiede zur Excel-Loesung liegen am Iterationskriterium, das beim Excelbsp.
# nicht so eindeutig gehandhabt wird wie hier, d.h., im Excel-Blatt geht die Iteration immer 
# drei Schritte, auch wenn die Konvergenz schon frueher  erreicht wird.
# Dadurch ergeben sich kleine Unterschiede in den Zahlen.





