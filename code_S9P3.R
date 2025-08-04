# Simulation setup
n <- 10^6
mu <- rnorm(n)
y <- rnorm(n) + mu
tau <- sample(c(-2, 2), prob=c(.5, .5), size = n, replace = TRUE)
# Note: The values for tau are -2 and 2!

F.perf <- function(x) pnorm(x - mu)
F.clim <- function(x) pnorm(x / sqrt(2))
F.unfocused <- function(x) 0.5*(pnorm(x - mu) + pnorm(x - mu - tau))
F.sign <- function(x) pnorm(x + mu)

# Point forecasts
mean.perf = mu
mean.clim = rep(0,n)
mean.unfocused = mu + tau/2
mean.sign = -mu

z = qnorm(0.9)
# The following function returns the quantiles of
# the unfocused forecast distribution!
q.unfocused <- function(p) {
  F = function(x) 0.5*(pnorm(x) + pnorm(x - 2))
  z.tau = optimize(f = function(x) abs(p - F(x)),
                   interval = c(0,2) + qnorm(p))$minimum
  return(z.tau + mu - ifelse(tau == -2,2,0))
}
# Correct, since F(q(alpha)) = alpha holds (approximately), e.g.
head(F.unfocused(q.unfocused(0.9)))

quant90.perf = mu + z
quant90.clim = rep(sqrt(2)*z,n)
quant90.unfocused = q.unfocused(0.9)
quant90.sign = -mu + z
prob.perf = 1-F.perf(2)
prob.clim = rep(1-F.clim(2),n)
prob.unfocused = 1-F.unfocused(2)
prob.sign = 1-F.sign(2)

# Murphy diagrams
# Using 'murphydiagram':
# install.packages("murphydiagram")
# library(murphydiagram)
# Use
# murphydiagram(mean.perf, mean.unfocused, y, colors = c('black','orange'), 
#               equally_spaced = TRUE, labels = NULL)
# or
# murphydiagram(quant90.clim,quant90.sign,y,functional="quantile",alpha=0.9,
#               colors=c('green','blue'),equally_spaced=TRUE,labels=NULL)
# to plot a Murphy-Diagram comparing two forecasts at a time.

# Alternative: Use 'murphydiagram2' (has to be installed from GitHub)
# Use 'remotes' package to install a package from GitHub
# install.packages("remotes")
# remotes::install_github("aijordan/murphydiagram2")
library(murphydiagram2)

# Mean
murphy.mean = murphydiag(mean.perf, mean.clim, mean.unfocused, mean.sign,
                         y = y, type = "mean")
plot(murphy.mean,col = c("black","green","orange","blue"),lty = 1,
     xlim = c(-3,3),xlab = expression("Parameter" ~ theta),ylab = "Mean Score")
plot(murphy.mean,col = c("black","green","orange","blue"),lty = 1,
     xlim = c(3,3.6),ylim = 4*c(0,0.008),
     xlab = expression("Parameter" ~ theta),ylab = "Mean Score")
# Note: The elementary expectile scores used by 'murphydiagram2' 
# are scaled differently (by a factor of 4).

# 90%-Quantile
murphy.quant90 = murphydiag(quant90.perf, quant90.clim, quant90.unfocused, 
                            quant90.sign,y = y,type = "quantile",level = 0.9)
plot(murphy.quant90,col = c("black","green","orange","blue"),lty = 1,
     xlim = c(-2,4),xlab = expression("Parameter" ~ theta),ylab = "Mean Score")
# Note: The elementary quantile scores used by 'murphydiagram2' 
# are scaled differently (by a factor of 2)

# Exceedance probability at threshold 2 (Prob(Y > 2))
murphy.prob = murphydiag(prob.perf, prob.clim, prob.unfocused, prob.sign,
                         y = ifelse(y > 2,1,0), type = "prob")
# produces the same Murphy diagram as
# murphy.prob = murphydiag(prob.perf, prob.clim, prob.unfocused, prob.sign,
#                          y = ifelse(y > 2,1,0), type = "mean")
plot(murphy.prob,col = c("black","green","orange","blue"),lty = 1,xlim = c(0,1),
     xlab = expression("Parameter" ~ theta),ylab = "Mean Score")
@