knoten = ["v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8"]
kante_12 = {
  "start": "v1",
  "ende":  "v2",
  "laenge": 3    
}
kante_13 = {
  "start": "v1",
  "ende":  "v3",
  "laenge": 2    
}
kante_24 = {
  "start": "v2",
  "ende":  "v4",
  "laenge": 5    
}
kante_31 = {
  "start": "v3",
  "ende":  "v1",
  "laenge": 1   
}
kante_32 = {
  "start": "v3",
  "ende":  "v2",
  "laenge": 1    
}
kante_42 = {
  "start": "v4",
  "ende":  "v2",
  "laenge": 4    
}
kante_43 = {
  "start": "v4",
  "ende":  "v3",
  "laenge": 2   
}
kante_45 = {
  "start": "v4",
  "ende":  "v5",
  "laenge": 9    
}
kante_46 = {
  "start": "v4",
  "ende":  "v6",
  "laenge": 5    
}
kante_56 = {
  "start": "v5",
  "ende":  "v6",
  "laenge": 8   
}
kante_64 = {
  "start": "v6",
  "ende":  "v4",
  "laenge": 11    
}
kante_67 = {
  "start": "v6",
  "ende":  "v7",
  "laenge": 6   
}
kante_68 = {
  "start": "v6",
  "ende":  "v8",
  "laenge": 2    
}
kante_87 = {
  "start": "v8",
  "ende":  "v7",
  "laenge": 3   
}
kanten = [kante_12, kante_13, kante_24, kante_31, kante_32, kante_42, kante_43, kante_45, kante_46, kante_56, kante_64, kante_67, kante_68, kante_87]
startknoten = "v5"

weglaenge = {
    "v1":   float('inf'),
    "v2":   float('inf'),
    "v3":   float('inf'),
    "v4":   float('inf'),
    "v5":   float('inf'),
    "v6":   float('inf'),
    "v7":   float('inf'),
    "v8":   float('inf'),
}
vorgaenger = {
    "v1":   None,
    "v2":   None,
    "v3":   None,
    "v4":   None,
    "v5":   None,
    "v6":   None,
    "v7":   None,
    "v8":   None,
}
weglaenge[startknoten] = 0
markierteKnoten = [startknoten]

while len(markierteKnoten) > 0:
    minWeglaenge = weglaenge[markierteKnoten[0]]
    h = markierteKnoten[0]
    for knoten in markierteKnoten:
        if weglaenge[knoten] < minWeglaenge:
            minWeglaenge = weglaenge[knoten]
            h = knoten
            
    nachfolger = []
    for kante in kanten:
        if kante["start"] == h:
            nachfolger.append(kante["ende"])
            
    for j in nachfolger:
        for kante in kanten:
            if kante["start"] == h and kante["ende"] == j and weglaenge[j] > weglaenge[h] + kante["laenge"]:
                weglaenge[j] = weglaenge[h] + kante["laenge"]
                vorgaenger[j] = h
                markierteKnoten.append(j)
    
    markierteKnoten.remove(h)
    
print(weglaenge)
print(vorgaenger)