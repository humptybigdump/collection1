## Beim Datensatz handelt es sich um den Datensatz, der in der Vorlesung zur
## Einführung der Linearen Regression verwendet wurde.
## Es handelt sich um Daten über Werbekampagnen in unterschiedlichen Märkten.

## Daten
## TV: Budget für TV Werbung in 1000 $
## radio: Budget für Radio in 1000 $
## newspaper: Budget für newspaper in 1000 $
## sales: Verkaufserlöse in 1000 $ -- unsere Zielvariable.

## Ziel ist, ein Modell zu schätzen, das die Verkaufserlöse in Abhängigkeit
## des eingesetzten Budgets für die verschiedenen Medien vorhersagt. 

##------------------------------------------------------------------------------

## Schritt 1: Daten einlesen, aufbereiten und visualisieren

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
adv <- read.csv("Advertising.csv")

str(adv)

## die Spalte X repräsentiert die ID, diese löschen wir für die folgenden
## Analysen
adv['X'] <- NULL

str(adv)

## Datenbereinigung
any(is.na(adv))


boxplot(adv)
plot(adv)


res <- cor(adv)  
round(res, 2)

corrplot(res)
