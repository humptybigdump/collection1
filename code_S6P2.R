## a)
# L2-norm for the normal distribution
L2norm <- function(sd) (2*sd)^(-0.5) * pi^(-0.25)

# quadratic score
QS <- function(y, mu, sd) -2*dnorm(y, mean = mu, sd = sd) + L2norm(sd)^2
# spherical score
SS <- function(y, mu, sd) -dnorm(y, mean = mu, sd = sd) / L2norm(sd)
# logarithmic score
LS <- function(y, mu, sd) (y-mu)^2/(2*sd^2) + log(sd) + 0.5*log(2*pi)
# Hyvaerinen score
HS <- function(y, mu, sd) 1/sd^2*((y-mu)^2/sd^2 - 2)

# plot
par(mar = c(3, 2, 2, 1))
y <- seq(-4, 4, len = 101)
matplot(y, cbind(QS(y, 0, 1), SS(y, 0, 1), LS(y, 0, 1), HS(y, 0, 1)),
        type="l", lty=c(1, 1, 1, 1))
legend("top", legend = c("QS", "SS", "LS", "HS"),
       lty = rep(1, 4), col = 1:4, xjust = .5, yjust = .5)

# b)
# quadratic score
QG <- function(sd) -L2norm(sd)^2
# spherical score
SG <- function(sd) -L2norm(sd)
# logarithmic score
LG <- function(sd) 0.5 + log(sd) + 0.5*log(2*pi)
# Hyvaerinen score
HG <- function(sd) -sd^(-2)

# plot
par(mar = c(3, 2, 2, 1))
sdev <- seq(.2, 1.2, len = 101)
matplot(sdev, cbind(QG(sdev), SG(sdev), LG(sdev), HG(sdev)),
        type="l", lty=c(1, 1, 1, 1),ylim = c(-10,2))
legend("bottomright", legend = c("QS", "SS", "LS", "HS"),
       lty = rep(1, 4), col = 1:4, xjust = .5, yjust = .5)

# c)
# squared L2 divergence when mu1 = mu2 and sd2 = 1
sqL2dist <- function(sd1) (2*pi*(sd1^2 + 1))^(-0.5)

# quadratic score
QD <- function(sd) L2norm(sd)^2 - 2*sqL2dist(sd) + L2norm(1)^2
# spherical score
SD <- function(sd) - sqL2dist(sd)/L2norm(sd) + L2norm(1)
# logarithmic score
LD <- function(sd) 0.5*(1/sd^2 - 1 + 2*log(sd))
# Hyvaerinen score
HD <- function(sd) (1 - 1/sd^2)^2

# plot
par(mar = c(3, 2, 2, 1))
sdev <- seq(.0001, 25, len = 1001)
par(mfrow = c(1, 1))
matplot(sdev, cbind(QD(sdev), SD(sdev), LD(sdev), HD(sdev)),
        type="l", lty=c(1, 1, 1, 1),ylim = c(0,5))
legend("top", legend = c("QS", "SS", "LS", "HS"),
       lty = rep(1, 4), col = 1:4, xjust = .5, yjust = .5)
@