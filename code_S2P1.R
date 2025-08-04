# Set up the simulation study by simulating/sampling each variable n times
n  <- 1e5
sigma1 <- 1
sigma2 <- sqrt(2)
a1 <- rnorm(n, sd = sigma1)
a2 <- rnorm(n, sd = sigma2)

# Derive forecasts p1, p2, success probability p3 and observation y
p1  <- pnorm(a1/sqrt(1 + sigma2))
p2  <- pnorm(a2/sqrt(1 + sigma1))
p3  <- pnorm(a1 + a2)
y  <- rbinom(n, size = 1, prob = p3)

# Reliability diagrams are  means to assess the reliability (i.e. calibration) 
# of probabilistic forecasts for dichotomous/binary events. 
# For a good/calibrated/reliable forecast, the observed relative 
# frequency corresponds with the forecasted probability (see also lecture notes).

# In order to derive a reliability diagram for a probability vector p 
# and binary events y and a given sample size
# - split the [0,1]-interval in a number of equally sized bins (nbins)
# - compute the border points of each bin (qseq)
# - arrange forecasts p and observations y in a data frame
# - evaluate per bin the average forecast probability and 
#   the relative frequency of the event
# - plot the data
# - add the theoretically optimum, i.e. a diagonal

reliability.diagram <- function(p, y, nbins = 10) {
  I <- nbins + 1
  qseq <- seq(0, 1, length.out=I)
  tupels <- data.frame(p = p, y = y)
  group.bins <- lapply(seq(nbins), function(i) {
    subset(tupels, (qseq[i] < p) & (p < qseq[i+1]))
  })
  avg_fcast <- sapply(group.bins, function(group) mean(group$p))
  ratios <- sapply(group.bins, function(group) mean(group$y))
  plot(avg_fcast, ratios, ylim = c(0, 1), xlim = c(0, 1),
       xlab = "forecast probability", ylab = "relative frequency")
  abline(0,1,lty = 2)
  # create inset histogram
  histo <- hist(p,breaks = nbins,plot = FALSE)
  barplot(histo$density/max(histo$density), width = 1/nbins,space = 0,
          add = TRUE, col = NA, border = "darkgrey")
}

par(mfrow = c(1, 3))

# Plot of the reliability diagrams
reliability.diagram(p1, y)
reliability.diagram(p2, y)
reliability.diagram(p3, y)

# As expected (ideal), both forecasts are reliable
# (no deviations from the diagonal)


# One could also use the verification package:
# install.packages("verification")
library(verification)
par(mfrow = c(1,1))
reliability.plot(verify(y, p1))
reliability.plot(verify(y, p2))
