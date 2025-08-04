## Beispielhaftes Vorgehen bei einer Zeitreihenanalyse anhand eines 
## exemplarischen Datensatzes nach dem Vorgehensmodell aus dem Skript

## Benoetigte R-Pakete:
library(forecast)
library(readxl)

## Evtl. muessen die Pakete vor dem library-Aufruf mittels des Aufrufs
## install.packages("Paketname") installiert werden.

##------------------------------------------------------------------------------

## Schritt 1: Datenaufbereitung

# Einlesen des Datensatzes:
AirPassengers <- read_excel("AirPassengers.xlsx")

# Anmerkung zum Einlesen: Entweder kompletten Dateipfad angeben oder schoener:
# Datensatzdokument am selben Ort wie das R-Dokument speichern und in RStudio
# die Option Session -> Set Working Directory -> To Source File Location waehlen
# und nur den Dokumentnamen des Datensatzes angeben (wie hier).
# Liegt der Datensatz in einem anderen Format als hier vor (z.B. sind die Spalten
# im Excel-Dokument durch Kommas statt der Excel-Spalten getrennt), so muss 
# zum korrekten Einlesen evtl. Inputparameter beachtet werden. Siehe dazu 
# die Hilfeseite der Funktion ?read_excel. 
# Alternativ kann in R-Studio versucht werden, den Datensatz mithilfe der Option
# Import Dataset einzulesen, der rechts oben ueber dem Workspace steht.  


# Ueberblick ueber die Daten:
str(AirPassengers)

# Der Datensatz enthaelt eine Spalte mit der Anzahl an Flugpassagieren in Mio 
# und dem zugehoerigen Monat. Die Daten sind also bereits monatsweise bereit-
# gestellt


# Datenbereinigung:
any(is.na(AirPassengers))

# Es gibt keine fehlenden Daten in dem Datensatz.
# Die beiden Variablen sind zur Analyse wichtig. Somit muss der Datensatz nicht
# bereinigt werden.


# Beschreibung der Anzahl an Flugpassagieren
hist(AirPassengers$Passengers, freq = FALSE, 
     main = "Histogramm der Anzahl an Flugpassagieren", xlab = "Anzahl", 
     ylab = "Dichte")
boxplot(AirPassengers$Passengers, main = "Boxplot der Anzahl an Flugpassigeren",
        ylab = "Anzahl")

# Anhand des Histogramms und des Boxplots ist zu sehen, dass in den meisten 
# Monaten zwischen 150 und 350 Mio Passagiere vorhanden waren. Deutlich groessere
# Werte treten jedoch auch auf, wodurch die Varianz insgesamt recht hoch ist.
# Das genaue arithm. Mittel und die Varianz werden hierdurch angegeben:
mean(AirPassengers$Passengers)
var(AirPassengers$Passengers)

##------------------------------------------------------------------------------

## Schritt 2: Deskriptive Analyse der Zeitreihe

# Visualisieren der Zeitreihe
timeSeries <- ts(AirPassengers$Passengers, start = c(1949, 1), 
                 end = c(1960, 12), frequency = 12)
timeSeries
plot(timeSeries, xlab = "Jahr", ylab = "Anzahl Flugpassagiere in Mio", 
     main = "Zeitreihe der Flugpassagierdaten")

# Die Funktion ts() formatiert den Datensatz in ein eigenes TimeSeries-Objekt.
# Dies erspart hier den mitunter laestigen Umgang mit Datumsformatierungen (man
# muesste sonst z.B. ueber die Funktion strptime() die Monatsspalte ins Datums-
# format bringen). Wichtig ist die Angabe der Parameter in ts(), d.h wann 
# startet die Zeitreihe, wann endet sie und welche Periode hat sie (falls
# bekannt). Naeheres dazu auf der Hilfeseite unter ?ts.

# Bei Betrachtung der Visualisierung der Zeitreihe fallen ein paar Dinge sofort 
# auf. Die Zeitreihe ist eindeutig nicht-stationaer. Sie besitzt sowohl einen 
# ansteigenden Trend als auch eine jaehrlich wiederkehrende Saisonfigur (also
# Periode 12). Zudem scheint die Variabilitaet mit dem Niveau anzusteigen.

# Deskriptive Masszahlen der Zeitreihe (Monatsmittel):
colMeans(t(matrix(timeSeries, ncol = 12)))

# Die Monatsmittel spiegeln den typischen Verlauf einer Saison (eines Jahres)
# wider. In den Wintermonaten werden im Mittel niedrigere Passagierzahlen 
# erzielt, im Sommer hingegen erkennbar mehr. Das ist natuerlich auch intuitiv,
# im Sommer machen die meisten Menschen Urlaub und die Passagierzahlen sind
# deswegen groesser.

# Deskriptive Masszahlen der Zeitreihe (Jahresmittel):
rowMeans(t(matrix(timeSeries, ncol = 12)))

# Anhand der Jahresmittel ist der Trend gut nachvollziehbar. Die Passagierzahlen
# nehmen in jedem Jahr deutlich zu. Nach 12 Jahren hat sich die Zahl so fast 
# vervierfacht.


# Zusammenfassung der deskriptiven Analyse:
# Stationaritaet: NEIN
# Trend: JA
# Saisonalitaet: JA
# Variabilitaetsaenderung: JA

##------------------------------------------------------------------------------

## Schritt 3 (Annahme Nicht-Stationaritaet): Finden plausibler Modelle

# Versuche zunaechst ein Dekompositionsmodell:
decomp <- decompose(timeSeries, type = "multiplicative")

# Die Funktion decompose() passt ein Dekompositionsmodell an ein ts()-Objekt an.
# Wichtig ist hier die Angabe des type. Da die Variabilitaet mit dem Niveau zu-
# nimmt, muss unbedingt ein multiplikatives Dekompositionsmodell gewaehlt werden.

plot(decomp)

# Die Anpassung des multiplikativen Dekompositionsmodells scheint geeignet. 
# Der Fehlerterm schwankt um 1 und besitzt relativ wenig Struktur (einziges
# Strukturmerkmal: die Werte in den mittleren Zeitabschnitten sind kleiner als
# an den Raendern).

decomp$trend
decomp$seasonal
decomp$random

# Diese Befehle geben die jeweilige Schaetzung des Trends, der Saisonfigur und
# des Fehlerterms aus. Fuer eine kompaktere Zusammenfassung kann auch schlicht
# das gesamte Modell ausgegeben werden:
decomp

# Versuche nun eine Anpassung in diesem Modell mittels der Methode nach 
# Holt-Winters (Exponentielles Glaetten 3. Ordnung):
HW <- HoltWinters(timeSeries, seasonal = "multiplicative")

# Ueber die Funktion Holt-Winters() kann diese Anpassung erreicht werden. Wichtig
# ist hier erneut die Angabe, ob es sich um ein additives oder multiplikatives 
# Modell handeln soll. Naeheres siehe Hilfe in ?HoltWinters

# Ausgabe der Schaetzungen der Koeffizienten:
HW$alpha
HW$beta
HW$gamma

# Visualisierung der Anpassung von Holt-Winters
plot(HW, col = c("darkblue", "darkred"))
legend("topleft", legend = c("beobachtete Werte", 
                             "angepasste Werte nach Holt-Winters"),
       lty = c(1, 1), col = c("darkblue", "darkred"))

# Vorhersage fuer nicht vorhandene Jahre mittels Holt-Winters Anpassung:
Pred <- predict(HW, n.ahead = 24)
Pred

# Mit der Funktion predict() koennen zukuenftige Werte vorhergesagt werden. Mit 
# dem Argument n.ahead wird festgelegt wie viele Werte vorhergesagt werden 
# sollen (hier: 24, also 24 Monate, also 2 Jahre).

# Visualisierung der Anpassung und der zukuenftigen Vorhersage:
plot(HW, Pred, col = c("darkblue", "darkred"))
legend("topleft", legend = c("beobachtete Werte", 
                             "angepasste Werte nach Holt-Winters"),
       lty = c(1, 1), col = c("darkblue", "darkred"))
  
  
  
