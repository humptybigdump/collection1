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



##------------------------------------------------------------------------------

# Versuche nun komplexere Modelle der ARIMA-Familie:

# Klar ist: Es liegt ein Trend vor, d.h. wir benoetigen Integration. 
#           Es liegt eine Saisonfigur vor, d.h. wir benoetigen SARIMA

# Zunaechst muss die Zeitreihe durch Transformationen stationaer gemacht werden.
# Bevor wir durch Differenzieren den Trend und die Saisonfigur eliminieren 
# können, muss zunaechst jedoch die Variabiltaetsaenderung eliminiert werden, 
# damit die Zeitreihe auch kovarianzstationaer ist. Hierfuer reicht Differenzieren
# nicht aus, sondern es muss eine andere Transformation vorgenommen werden.
# Sogenannte Varianzstabilisierende Transformationen fuehren uns hier zum Ziel.
# Der einfachste Vertreter ist die Anwendung der log-Funktion.

logTimeSeries <- log(timeSeries)
plot(logTimeSeries, ylab = "logarithmierte Anzahl", xlab = "Jahr", 
     main = "Logarithmus-Transformation der Flugpassagierdaten")

# Wir sehen: Die Variabiltaetsaenderungen sind verschwunden. Es liegen nun 
# konstante Schwankungen vor. Mit dieser Zeitreihe wird nun weiter gearbeitet
# und "weiter stationaer" gemacht.

# Eliminieren des Trends durch Differenzieren:
dfTrend <- diff(log(timeSeries), lag = 1)

# Die Funktion diff() differenziert die Zeitreihe. Ueber das Argument lag kann
# angegeben werden mit welchem Zetpunkt eine Beobachtung subtrahiert wird,
# zur Trendeliminierung wird dafuer logischerweise der Wert zum Zeitpunkt (lag)
# zuvor benutzt, also lag = 1. Mehr dazu in der Hilfe ?diff

# Visualisierung:
plot(dfTrend, ylab = "Differenzen", xlab = "Jahr", 
     main = "Differenzen 1. Ordnung der logarithmierten Flugpassagierdaten")

# Einmaliges Differenzieren reicht aus, um den Trend zu eliminieren. Damit
# die Zeitreihe stationaer wird, muss aber immer noch die Saisonfigur bereinigt
# werden. Dafuer wird diese transformierte Zeitreihe nochmal transformiert.

# Eliminieren der Saisonfigur durch Differenzieren der zugehoerigen Saisonwerte:
dfTrendSeason <- diff(dfTrend, lag = 12)

# Zum Bereinigen der Saison werden die Werte mit dem jeweiligen Wert von
# der Saison zuvor differenziert (lag = 12).

# Visualisierung:
plot(dfTrendSeason, ylab = "Differenzen", xlab = "Jahr", 
     main = "Saisonbereinigung")

# Nun scheint die Zeitreihe stationaer zu sein und ein entsprechendes 
# SARIMA-Modell kann angepasst werden. Dazu muessen, wie im Skript beschrieben,
# der saisonale Teil und der "regulaere" Teil getrennt voneinander betrachtet
# werden. Wir fangen mit dem saisonalen Teil an.

# Allgemeine Berechung der Autokorrelationen und partiellen Autokorrelationen:
acor <- acf(dfTrendSeason, lag.max = 12*12, plot = FALSE) 
pacor <- pacf(dfTrendSeason, lag.max = 12*12, plot=FALSE) 

# Hierfuer werden die Funktionen acf() und pacf() benutzt. Das Argument 
# plot = FALSE gibt an, dass erstmal keine Visualisierung vorgenommen wird.
# Mit lag.max wird gesteuert, fuer wie viele Zeitabstaende (Lags) die acf bzw. 
# pacf berechnet werden soll. 

# Visualisierung der acf und pacf des saisonalen Teils:
plot(acor[1 * 1:12])
plot(pacor[1 * 1:12])

# Vorsicht: In der acf und pacf sind die Lags hier mit der Periode normiert, d.h.
# um die saisonalen Lags zum Zeitabstand h = 12, 24, 36,.. auszugeben, muss auf
# die Lags 1, 2, 3, ... (12/12, 24/12, 36/12, ...) zugegriffen werden.

# Die acf und pacf des saisonalen Teils sind sich sehr aehnlich. Bei beiden 
# ist das erste Lag signifikant von 0 verschieden, alle anderen Lags nicht. 
# Ein abfallendes Muster ist bei beiden dennoch eher weniger zu sehen, am 
# ehesten noch bei der PACF. Deswegen koennte ein MA(1)-Modell angenommen werden.
# Moeglich ist aber auch ein RandomWalk, d.h. keine MA- oder Ar-Ordnungen.
# Zusammenfassend in Frage kommen fuer den saisonalen Teil somit:
# ARIMA(0,1,1) oder ARIMA(0,1,0)

# Nun der regulaere Teil:
# Visualisierung
plot(acor[seq(0, 1, 1/12)])
plot(pacor[seq(0, 1, 1/12)])

# Vorsicht: Die acf startet in R typischerweise bei Lag 0, dort ist die 
# Korrelation natuerlich maximal (siehe Skript). Dieser Wert muss bei der 
# Analyse aussen vorgelassen werden. Die pacf startet hingegen bei
# 1/12, dort werden alle Werte betrachtet.
# Bei beiden Graphiken ist erneut Lag1 signifikant von 0 verschieden. In der
# acf ist danach ein deutliches sinusfoermiges Abfallen zu erkennen mit 
# vereinzelnten Ausreissern, die hier aber nicht weiter ins Gewicht fallen.
# In der pacf fallen die Werte hingegen nicht ganz so deutlich. Hier gibt es 
# ein paar mehr Ausreisser. Somit scheint ein AR(1)-Modell plausibel. Im 
# Zweifelsfall ist aber auch MA(1) durchaus angemessen.
# Insgesamt haben wir somit fuer den regulaeren Teil ein ARIMA(1,1,0)-Modell oder
# ARIMA(0,1,1)-Modell detektiert.

# Zusammen mit dem saisonalen Teil ergibt das insgesamt ein 
# SARIMA(1,1,0)(0,1,0)-Modell,
# SARIMA(1,1,0)(0,1,1)-Modell,
# SARIMA(0,1,1)(0,1,1)-Modell oder
# SARIMA(0,1,1)(0,1,0)-Modell!

##------------------------------------------------------------------------------

## Schritt 4: Auswahl des besten in Frage kommenden Modells:

# Anpassung der in Frage kommenden ARIMA-Modelle (auf die logarithmierten Daten):
SARIMA110010 <- Arima(logTimeSeries, order = c(1, 1, 0), 
                      seasonal = list(order = c(0, 1, 0), period = 12))
SARIMA110011 <- Arima(logTimeSeries, order = c(1, 1, 0), 
                      seasonal = list(order = c(0, 1, 1), period = 12))
SARIMA011011 <- Arima(logTimeSeries, order = c(0, 1, 1), 
                      seasonal = list(order = c(0, 1, 1), period = 12))
SARIMA011010 <- Arima(logTimeSeries, order = c(0, 1, 1), 
                      seasonal = list(order = c(0, 1, 0), period = 12))

# Anpassung geschieht mittels der Funktion Arima() aus dem R-Paket forecast.
# Alternativ kann auch die Funktion arima() aus dem Basisprogramm benutzt werden.
# Der Input ist in beiden Faellen aehnlich. Im Argument order wird
# die ARIMA-Ordnung des regulaeren Teils angegeben. Im Argument seasonal 
# wird unter dem Listeneintrag order die ARIMA-Ordnung des saisonalen Teils
# sowie unter period die periode angegeben.

# Berechnung des AIC:
SARIMA110010$aic
SARIMA110011$aic
SARIMA011011$aic
SARIMA011010$aic

# Das geringste AIC weist SARIMA(0, 1, 1)(0, 1, 1) auf. Verwende also dieses 
# Modell zur Anpassung.

plot(SARIMA011011$x, col = "darkblue", xlim = c(1950, 1963), ylim = c(4.5, 6.8),
     xlab = "Jahr", ylab = "log. Werte")
lines(SARIMA011011$fitted, col = "darkred")

# Die Anpassung scheint gut zu sein. Der Verlauf kann nachvollzogen werden.
# Nun koennen Jahre vorhergesagt werden, fuer die keine Daten vorliegen:
predSARIMA <- predict(SARIMA011011, n.ahead = 24)
abline(v = 1961, lty= 3)
lines(predSARIMA$pred, col = "darkred")
legend("topleft", legend = c("beobachtete logarithmierte Werte", 
                             "angepasste Werte nach SARIMA(1,1,0)(1,1,0)"),
       lty = c(1, 1), col = c("darkblue", "darkred"))

# Achtung: Dies war natuerlich noch alles fuer die logarithmierte Zeitreihe, die
# wir benoetigten, um eine stabile Varianz und eine geeignete Modellfindung
# zu gewaehrleisten. Nun koennen die Werte ruecktransformiert werden, um die
# Anpassung fuer die Originalzeitreihe zu erhalten. Zur Ruecktransformation
# muss einfach stets die Inverse des Logarithmus verwendet werden, also
# die Exponentialfunktion. Damit ergibt sich:

plot(exp(SARIMA011011$x), col = "darkblue", xlim = c(1950, 1963), 
     ylim = c(100, 700), xlab = "Jahre", ylab = "Anzahl Passagiere (in Mio)")
lines(exp(SARIMA011011$fitted), col = "darkred")
abline(v = 1961, lty= 3)
lines(exp(predSARIMA$pred), col = "darkred")
legend("topleft", legend = c("beobachtete Werte", 
                             "angepasste Werte nach SARIMA(1,1,0)(1,1,0)"),
       lty = c(1, 1), col = c("darkblue", "darkred"))



##------------------------------------------------------------------------------

## Das war das klassische Vorgehen. Alternativ kann das R-Paket forecast von 
## Hyndman und Athranasopoulos verwendet werden, das ein automatisierteres
## Vorgehen benutzt. Dies wird im Folgenden kurz vorgestellt:

auto.arima(logTimeSeries)
# Mit der Funktion auto.arima wird automatisch jenes Modell SARIMA-Modell bestimmt
# welches den besten Wert eines Modellwahlkriteriums erzielt. Welches Modellwahl-
# kriterium genommen wird, wie viele Modelle untersucht werden und weiteres
# ist ausfuehrlich in der Hilfeseite und dem im Skript referenzierten Buch
# beschrieben.
# In diesem Fall wurde auto.arima mit den Default-Einstellungen berechnet. 
# Das beste Modell ist aus dem Output ersichtlich (zweite Zeile dort). 
# Es ist das SARIMA(0,1,1)(0,1,1)-Modell mit der Periode 12, welches wir
# bereits oben im klassischen Vorgehen gefunden haben.

# Auch fuer das exponentielle Glaetten gibt es eine automatische Funktion, 
# die aehnlich funktioniert:
ets(timeSeries)

# Hier sind die nach dem ets-Algorithmus optimalen Parameter eines Modells
# des expoentiellen Glaettens angegeben.
# Fuer weitere Interpretationen des Outputs siehe auch hier die Hilfeseite ?ets
# sowie das im Skript referenzierte Buch.