import random

def getBinFillLevel(consideredBin):
    fillLevel = 0
    for size in consideredBin["sizes"]:
        fillLevel = fillLevel + size
    return fillLevel

def nextFit(sizes, decreasing):
    sizes = sizes.copy()
    if decreasing:
        sizes.sort()
        sizes.reverse()
    bins = []
    if len(sizes) > 0 and len(bins) == 0:
        bins.append({"sizes": set()})
    indexOfCurrentBin = 0
    for size in sizes:
        if size + getBinFillLevel(bins[indexOfCurrentBin]) <= 1:
            bins[indexOfCurrentBin]["sizes"].add(size)
        else:
            bins.append({})
            indexOfCurrentBin = indexOfCurrentBin + 1
            bins[indexOfCurrentBin]["sizes"] = {size}
    return bins

def firstFit(sizes, decreasing):
    sizes = sizes.copy()
    if decreasing:
        sizes.sort()
        sizes.reverse()
    bins = []
    if len(sizes) > 0 and len(bins) == 0:
        bins.append({"sizes": set()})
    for size in sizes:
        sizePacked = False
        firstBinIndex = 0
        while not sizePacked and firstBinIndex < len(bins):
            if size + getBinFillLevel(bins[firstBinIndex]) <= 1:
                bins[firstBinIndex]["sizes"].add(size)
                sizePacked = True
            else:
                firstBinIndex = firstBinIndex + 1
        if not sizePacked:
            bins.append({})
            bins[len(bins) -  1]["sizes"] = {size}
    return bins

def bestFit(sizes, decreasing):
    sizes = sizes.copy()
    if decreasing:
        sizes.sort()
        sizes.reverse()
    bins = []
    if len(sizes) > 0 and len(bins) == 0:
        bins.append({"sizes": set()})
    for size in sizes:
        bestBinIndex = -1
        bestFillLevel = -1
        for i in range(0, len(bins)):
            if size + getBinFillLevel(bins[i]) <= 1 and getBinFillLevel(bins[i]) > bestFillLevel:
                bestBinIndex = i
                bestFillLevel = getBinFillLevel(bins[i])
        if bestBinIndex != -1:
            bins[bestBinIndex]["sizes"].add(size)
        else:
            bins.append({})
            bins[len(bins) -  1]["sizes"] = {size}
    return bins

random.seed(0)
sizes = []
for i in range(0, 250):
    sizes.append(random.random())
print("NF:", len(nextFit(sizes, False)))
print("NFD:", len(nextFit(sizes, True)))
print("FF:", len(firstFit(sizes, False)))
print("FFD:", len(firstFit(sizes, True)))
print("BF:", len(bestFit(sizes, False)))
print("BFD:", len(bestFit(sizes, True)))    