### Bemessung Extremwerte
# j.wienhoefer@kit.edu

 ## Iller

 # Daten einlesen  - Pfad anpassen!
 ill <- read.csv2("./UPLOAD/7_1_jaehrliche_reihe_iller.csv", dec=".")

 # Momente der Reihen
 mw1 <- mean(ill[ill$Jahr<1999,2])
 sd1 <- sd(ill[ill$Jahr<1999,2])

 mw2 <- mean(ill[,2])
 sd2 <- sd(ill[,2])

 # Funktion: Wert qx finden zu Pu, MW, STABW
 # umgestellte Formel der Gumbelverteilung
  gumbinv <- function(Pux, mw, stabw)
  { a <- pi / (stabw * sqrt(6))
    b <- mw - (0.5722/a)
    qx <- b - 1/a * log(-log (Pux))
  return(qx)
  }

 # gesuchte Jährlichkeiten
  Tn <-c(2, 5, 10, 50, 100, 1000)
 # daraus Pu
  Pu <- 1- 1/Tn

 # daraus Bemessungswerte für Zeitraum 1 bzw. 2 ableiten
 gumb1 <- gumbinv(Pu, mw1, sd1)
 gumb2 <-   gumbinv(Pu, mw2, sd2)


 # Pu für 400 m³ finden
  gumb <- function(qx, mw, stabw)
   {a <- pi / (stabw * sqrt(6))
    b <- mw - (0.5722/a)
    pux <- exp(-exp(-a*(qx-b)))
    }

  pu1 <- gumb(400, mw1, sd1)
   1/(1-pu1)
  pu2 <- gumb(400, mw2, sd2)
   1/(1-pu2)

