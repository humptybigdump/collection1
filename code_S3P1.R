# c)
n <- 1e+4
mu <- rnorm(n)
y <- rnorm(n) + mu
tau <- sample(c(-1, 1), prob=c(.5, .5), size = n, replace = TRUE)

# CDFs
F1 <- function(x) pnorm(x - mu)
F2 <- function(x) pnorm(x / sqrt(2))
F3 <- function(x) 0.5*(pnorm(x - mu) + pnorm(x - mu - tau))
F4 <- function(x) pnorm(x + mu)

# PDFs
f1 <- function(x, i) dnorm(x - mu[i])
f2 <- function(x, i) dnorm(x / sqrt(2)) / sqrt(2)
f3 <- function(x, i) 0.5*(dnorm(x - mu[i]) + dnorm(x - mu[i] - tau[i]))
f3_0 <- function(x, i) 0.5*(dnorm(x - mu[i]))
f3_1 <- function(x, i) 0.5*(dnorm(x - mu[i] - tau[i]))
f4 <- function(x, i) dnorm(x + mu[i])

# Draw exemplary forecasts
par(mfrow = c(1, 1))
cols <- RColorBrewer::brewer.pal(n = 4,
                                 name = "Dark2")
x0 <- seq(-3, 3, 0.01)

## First sample
# Climatological
plot(x = x0, y = f2(x = x0, i = 1), 
     col = cols[2], type = "l", lwd = 2,
     ylim = range(f1(x = x0, i = 1)))
abline(v = 0, lty = 2, col = "lightgrey")
legend("topleft", legend = c("Perfect", "Clim", "Unfocused", "Sign-rev."), 
       col = cols, lty = 1, lwd = 3)
# Perfect
abline(v = mu[1], lty = 2, col = cols[1])
lines(x = x0, y = f1(x = x0, i = 1), col = cols[1], lwd = 2)
# Sign-reversed
abline(v = -mu[1], lty = 2, col = cols[4])
lines(x = x0, y = f4(x = x0, i = 1), col = cols[4], lwd = 2)
# Unfocused
lines(x = x0, y = f3(x = x0, i = 1), col = cols[3], lwd = 2)
lines(x = x0, y = f3_0(x = x0, i = 1), col = cols[3], lwd = 2, lty = 2)
lines(x = x0, y = f3_1(x = x0, i = 1), col = cols[3], lwd = 2, lty = 2)

# Some more forecasts
for(i in sample(2:n, 3)){
  plot(x = x0, y = f1(x = x0, i = i), 
       col = cols[1], type = "l", lwd = 2, main = paste0("Sample: ", i))
  lines(x = x0, y = f2(x = x0, i = i), col = cols[2], lwd = 2)
  lines(x = x0, y = f3(x = x0, i = i), col = cols[3], lwd = 2)
  lines(x = x0, y = f4(x = x0, i = i), col = cols[4], lwd = 2)
  abline(v = 0, lty = 2, col = "lightgrey")
  legend("topleft", legend = c("Perfect", "Clim", "Unfocused", "Sign-rev."), 
         col = cols, lty = 1, lwd = 3)
}

par(mfrow = c(2, 2))
hist(F1(y))
hist(F2(y))
hist(F3(y))
hist(F4(y))

marg.calibration.plot <- function(predCDF, xlim = c(-3, 3)) {
  x <- seq(xlim[1], xlim[2], length.out = 101)
  ecdfY <- sapply(x, function(x) mean(y <= x))
  meanpredCDF <- sapply(x, function(x) mean(predCDF(x)))
  plot(x, ecdfY, type="l")
  lines(x, meanpredCDF, col="red")
}

par(mfrow = c(2, 4))
marg.calibration.plot(F1)
marg.calibration.plot(F2)
marg.calibration.plot(F3)
marg.calibration.plot(F4)

# Difference plot: Q(Y <= y) - E_Q F_3(y)
marg.calibration.diff.plot <- function(predCDF, xlim = c(-3, 3)) {
  x <- seq(xlim[1], xlim[2], length.out = 101)
  ecdfY <- sapply(x, function(x) mean(y <= x))
  meanpredCDF <- sapply(x, function(x) mean(predCDF(x)))
  plot(x, ecdfY - meanpredCDF, type="l", ylim = c(-0.1, 0.1))
  abline(h = 0, col="grey")
}

marg.calibration.diff.plot(F1)
marg.calibration.diff.plot(F2)
marg.calibration.diff.plot(F3)
marg.calibration.diff.plot(F4)

## Draw theoretical quantities (Q(Y <= y) and E_Q F_3(y))
# F_3 is not marginally calibrated
par(mfrow = c(1, 2))
plot(function(x) 0.5*(pnorm(x/sqrt(2)) + 0.5*pnorm((x-1)/sqrt(2)) + 0.5*pnorm((x+1)/sqrt(2))), 
     xlim = c(-5,5),ylab = "E[F(x)]")
plot(function(x) pnorm(x/sqrt(2)),xlim = c(-5,5),col = "red",add = TRUE)

# Draw theoretical difference (Q(Y <= y) - E_Q F_3(y))
marg.calibration.diff.plot(F3, xlim = c(-3, 3))
fn_diff <- function(x){ 
  pnorm(x/sqrt(2)) - 0.5*(pnorm(x/sqrt(2)) + 0.5*pnorm((x-1)/sqrt(2)) + 0.5*pnorm((x+1)/sqrt(2))) }
lines(x = x0, y = fn_diff(x = x0), lty = 2)


# d)
mu <- 0
tau <- 1
quantileF3 <- function(p) {
  optimize(f = function(x) abs(p - F3(x)),
           interval = c(0, 1) + qnorm(p))$minimum
}
length <- c(qnorm(0.95) - qnorm(0.05),
            sqrt(2)*(qnorm(0.95) - qnorm(0.05)),
            quantileF3(0.95) - quantileF3(0.05),
            qnorm(0.95) - qnorm(0.05))
names(length) <- c("F1", "F2", "F3", "F4")
round(length,2)
