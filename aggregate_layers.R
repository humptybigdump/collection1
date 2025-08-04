# Read separate layers
herbs <- read.csv("Daten_Gelaendeuebungen24/herb_layer.csv")
shrubs <- read.csv("Daten_Gelaendeuebungen24/shrub_layer.csv")
trees <- read.csv("Daten_Gelaendeuebungen24/trees.csv")
plots <- read.csv("Daten_Gelaendeuebungen24/plotdata.csv")

# Merge all layers
alllay <- rbind(herbs, shrubs, trees)

# Order by name (not a necessary step)
alllay <- alllay[order(alllay[, 1]), ]

# Source Hagen-Fischer
source("Daten_Gelaendeuebungen24/hagen_fischer.R")

# The function needs values between 0 and 100 - transform
alllay[, -1] <- alllay[, -1] / 100

# Apply the function to aggregate rows by species
hf <- aggregate(. ~ species, data = alllay, FUN = hagen_fischer)
