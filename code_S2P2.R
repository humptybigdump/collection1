# Set up the simulation study by simulating/sampling each variable n times
n  <- 1e5
x0 <- rnorm(n)
x1 <- rnorm(n)
e  <- rnorm(n)
b  <- rnorm(n) * 0.5

# Derive observation and event A
y  <- x0 + 0.7*x1 + e
a  <- (y > 0)

# Reliability diagram (see code_S2P1.R)

reliability.diagram <- function(p, a, nbins = 10) {
  I <- nbins + 1
  qseq <- seq(0, 1, length.out=I)
  tupels <- data.frame(p = p, a = a)
  group.bins <- lapply(seq(nbins), function(i) {
    subset(tupels, qseq[i] < p & p < qseq[i+1])
  })
  avg_fcast <- sapply(group.bins, function(group) mean(group$p))
  ratios <- sapply(group.bins, function(group) mean(group$a))
  plot(avg_fcast, ratios, ylim=c(0, 1), xlim=c(0, 1),xlab = "forecast probability",ylab = "relative frequency")
  abline(0,1,lty = 2)
  # create inset histogram
  histo = hist(p,breaks = nbins,plot = FALSE)
  barplot(histo$density/max(histo$density),width = 1/nbins,space = 0,add = TRUE,col = NA,border = "darkgrey")
}

# Compute the PIT-values
F1 <- function(y) pnorm((y - x0)/sqrt(0.7^2 + 1))
F2 <- function(y) pnorm(y - x0 - 0.7*x1 - abs(b))

p1 <- 1 - F1(0)
p2 <- 1 - F2(0)

par(mfrow = c(1, 2))

# Plot of the PIT values
hist(F1(y))
hist(F2(y))

# PIT of F2 right-skewed, observations too often too 
# low compared to the forecast distribution
# Forecast 2 therefore positively biased
# Forecast 1 appears perfectly calibrated (up to some noise)

# Plot of the reliability diagrams
reliability.diagram(p1, a)
reliability.diagram(p2, a)

# Forecast 1 is reliable, while Forecast 2 is not reliable
# (deviates from the diagonal)


# One could also use the verification package:
# install.packages("verification")
library(verification)
par(mfrow = c(1,1))
reliability.plot(verify(a, p1))
reliability.plot(verify(a, p2))
