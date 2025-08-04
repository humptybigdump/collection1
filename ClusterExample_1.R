### Beispiel eines R-Skripts zum Thema Clusteranalyse

## Lade zunaechst die benoetigten Pakete (evtl. zuvor install.packages()!)
library(MASS)
library(cluster)
library(dbscan)
library(fpc)
library(factoextra) 

###-----------------------------------------------------------------------------
## Besipielsdatensatz 
###-----------------------------------------------------------------------------

## Im Folgenden simulieren wir einen Datensatz mit drei verschiedenen Clustern.
## Dazu benutzen wir hier die Funktion mvrnorm aus dem Paket MASS. Dadurch
## erzeugt man sich mehrdimensionale Normalverteilungszufallszahlen. In diesem
## Beispiel ist unsere Dimension 2 und wir benutzen drei verschiedene Normal-
## verteilungen mit unterschiedlichen Mittelwerten, um drei Cluster zu 
## simulieren. Jedes Cluster enthält 100 Zufallszahlen. 

Punkte1 <- mvrnorm(100, mu = c(1, -4), 
                   Sigma = rbind(c(1, 0), c(0, 1)))
Punkte2 <- mvrnorm(100, mu = c(-4, 5), 
                   Sigma = rbind(c(1.3, 0), c(0, 1.3)))
Punkte3 <- mvrnorm(100, mu = c(5, 2), 
                   Sigma = rbind(c(0.7, 0), c(0, 0.7)))

## Siehe auch die Hilfe von mvrnorm

## Nun werden die Daten in einen data.frame umgewandelt, damit ein gebuendelter
## Datensatz vorliegt. 
M <- as.data.frame(rbind(Punkte1, Punkte2, Punkte3))
str(M)

## Wir haben also insgesamt 300 Beobachtungen bzgl. 2 Variablen vorliegen.
## Diese gilt es nun mittels einer Clusteranalyse zu klassifizieren.
## Vorab eine Visualisierung der Daten, um einen Ueberblick zu erlangen.

plot(M, xlab = "x", ylab = "y", main = "Datensituation 1", asp = 1)

## Die drei verschiedenen Cluster sind gut erkennbar. Sie besitzen zudem eine
## sphaerische (auch: globale, runde) Form.

###-----------------------------------------------------------------------------
## Teil 1: partitionierende Algorithmen
###-----------------------------------------------------------------------------

## Im ersten Schritt werden partitionierende Verfahren verwendet, z.B. kMeans
## WICHTIG: Bei partitionierenden Verfahren muss die gewuenschte Clusterzahl 
## vorgegeben werden ueber den Inputparameter centers bzw. k.
## Wir entscheiden uns aufgrund unseres Vorwissens fuer 3 Cluster:
kM3 <- kmeans(M, centers = 3, iter.max = 100)

kM3$centers
kM3$cluster


## Mittels fviz_cluster koennen aus dem Paket factoextra koennen die Ergebnisse
## geeignet visualisiert werden. Siehe dazu auch die Hilfeseite.
fviz_cluster(kM3, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

## Wir sehen: Der Algorithmus konnte ein gutes Clustering erkennen.

## Was passiert, wenn wir kein Vorwissen haetten und stattdessen die Clusterzahl
## als 2 waehlen:
kM2 <- kmeans(M, centers = 2)

fviz_cluster(kM2, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

## Das Clustering hier scheint nicht geeignet. Es wurden zwei Cluster zu einem
## zusammengefasst. Vorsicht somit bei partitionierenden Verfahren! Die Cluster-
## anzahl muss sorgfaeltig gewaehlt werden.

## Beispielsweise über die "elbow method" bei der Visualisierung der 
## Intra-Cluster Fehlerquadratsumme (Within Cluster Sum of Squares)
wss <- numeric() 
for (i in 1:10) {
  km <- kmeans(M, centers = i)
  wss[i] <- km$tot.withinss
  print(km$tot.withinss)
}

plot(wss, type = "b", main = "Wahl von k")

## Der Plot zeigt, dass 3 ein sinnvoller Wert für k ist.

## Aehnlich funktioniert der Algorithmus pam (partioning around medoids).
## Grobe Idee: Statt Mittelwerte (wie bei kMeans) bilden bei diesem Algorithmus
## Objekte aus dem Datensatz selbst die Clusterzentren bzgl. derer die Distanz 
## minimiert wird. 


## Auch hier zweimal das Beispiel mit k = 3 und k = 2. Das Ergebnis ist hier
## sehr aehnlich.

pam3 <- pam(M, k = 3)

pam3$medoids
pam3$clustering

fviz_cluster(pam3, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

pam2 <- pam(M, 2)

fviz_cluster(pam2, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

###-----------------------------------------------------------------------------
## Teil 2: hierarchische Verfahren
###-----------------------------------------------------------------------------

## Im zweiten Schritt wenden wir uns nun hierarchischen Verfahren zu. Wie im 
## Skript beschrieben bilden diese kein eigenes Clustering, sondern berechnen
## alle moeglichen Clusterings nach einer top-down bzw. bottom-up Methode.
## Als Kriterium dient die Distanz der Objekte zueinander. 
## Dementsprechend kalkulieren wir zunaechst die Distanzmatrix mittels der 
## Funktion dist.

dissimilarity <- dist(M, method = "euclidean")

## Dadurch kann nun ein hierarchisches Verfahren benutzt werden. In diesem
## Beispiel Single Linkage. Siehe in der Hilfe von hclust fuer andere 
## Linkage-Verfahren.
hiCl <- hclust(dissimilarity, method = "complete")

## Ein Dendrogramm kann man dan mit dem Befehl plot erstellen:
plot(hiCl, main = "dendrogramm", hang = -1)

## Wir sehen: Auch hier bilden sich drei Cluster. Die Nummern geben den Index
## der Beobachtungen im Datensatz an.
## Den Clustervektor ausgeben kann man mit der Funktion cutree. Hierzu muss
## angegeben werden, für wie viele Cluster man sich bei Betrachtung des 
## Dendrogramms entscheidet.

hiClclusters <- cutree(hiCl, k = 3)
hiClclusters

fviz_cluster(list(data = M, cluster = hiClclusters), geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

## Clusterzentren:
colMeans(M[which(hiClclusters == 1),])
colMeans(M[which(hiClclusters == 2),])
colMeans(M[which(hiClclusters == 3),])


###-----------------------------------------------------------------------------
## Teil 3: dichtebasierende Verfahren
###-----------------------------------------------------------------------------

## Dichtebasierende Verfahren sind etwas komplexer. Das Vorgehen ist hier
## grundlegend anders. Fuer jeden Punkt wird hier untersucht, ob er genuegend
## "dicht" liegt, um in ein Cluster aufgenommen zu werden. 
## "Dicht" bedeutet hier, dass in seiner Nachbarschaft genuegend Punkte liegen.
## Daraus ergeben sich die Fragen: Was bedeutet Nachbarschaft und wie
## viel sind "genuegend Punkte"?
## Genau das sind die beiden Eingabeparameter des Algorithmus dbscan. 
## Mittels minPts wird festgelegt, wie viele Punkte in der Nachbarschaft 
## eines Punktes liegen muessen, damit dieser Punkt als "dicht" gilt.
## Mittels eps wird die Nachbarschaft definiert, d.h. in welchem 
## (Distanz)radius des Punktes wird gesucht. 
## Ein Cluster wird dann erschaffen, wenn es Punkte gibt, die entsprechend 
## dieser Kriterien als dicht gelten. Diese werden in das Cluster mit 
## aufgenommen sowie auch alle Punkte in der Nachbarschaft von dichten
## Punkten. Ist ein Punkt isoliert, so wird er als Rauschen erkannt 
## (keinem Cluster zugehoerig).


## Wichtig ist eine sorgfaeltige Wahl der beiden Parameter. Fuer minPts ist
## in normalen Situationen oft ein Wert zwischen 4-20 sinnvoll.
## Legt man sich fuer einen Wert von minPts fest, so kann man mit der
## folgenden Methode eps sinnvoll waehlen. In dem Besipiel benutzen wir minPts 
## = 10:

## Fuer jedes Objekt wird die Distanz zu seinem 10-naechsten Nachbarn berechnet. 
## Das ist also die Distanz, die fuer den Nachbarschaftsradius mindestens noetig
## ist, damit das Objekt als "dicht" gilt. Diese Werte werden nach ihrer Groesse
## geordnet und in einem Plot abgetragen. Dies kann mit der Funktion 
## kNNdistplot() aus dem Paket dbscan geschehen:

kNNdistplot(M, k = 10)

## Wir suchen in dieser Graphik einen Knick, d.h. eine Stelle ab der der Graph
## rapide ansteigt. Dieser waere hier ungefaehr bei 1.4 zu finden. 

abline(h = 1.4)

## Alle Punkte, die eine 10-naechste Nachbar Distanz oberhalb dieser Grenze
## aufweisen gelten als "nicht dicht" im Sinne unserer Kriterien. D.h. sie 
## werden nur dann einem Cluster zugeordnet, wenn sie in der Nachbarschaft eines
## "dichten" Punktes liegen. Ist das nicht der Fall, werden sie als Rauschen 
## klassifiziert.

## Wende nun dbscan mit den bestimmten Parametern an:
db <- fpc::dbscan(M, eps = 1.4, MinPts = 10)
db$cluster

fviz_cluster(db, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

## Das Ergebnis ist erfreulich. Nur vereinzelt wurden Punkte als Ausreisser 
## klassifiziert. Der Rest scheint korrekt zugeordnet worden zu sein.

## Clusterzentren:
colMeans(M[which(db$cluster == 1),])
colMeans(M[which(db$cluster == 2),])
colMeans(M[which(db$cluster == 3),])


## Die Abhaengigkeit des Algorithmus bzgl. seiner Parameter zeigt folgendes
## Beispiel. Haetten wir den Nachbarschaftsradius bei eps = 0.4 gewaehlt
## also viel niedriger, haetten wir deutlich mehr Objekte als Rauschen einge-
## ordnet.


kNNdistplot(M, k = 10)
abline(h = 0.4)
db <- fpc::dbscan(M, eps = 0.4, MinPts = 10)
fviz_cluster(db, data = M, geom = "point",
             stand = FALSE, ellipse = FALSE, main ="",
             show.clust.cent = FALSE, palette = "jco", 
             ggtheme = theme_classic())

## Tatsaechlich waeren sogar ganz andere Cluster entstanden. Demzufolge sollte
## immer der knnDistplot bei der Bestimmung des eps-Parameters zu Rate
## gezogen werden.



