# Simulation study 7.3.1 
# Understanding combination aggregation methods
# Here Traditional linear pool (TLP)
#      Spread-adjusted linear pool (SLP)
#      Beta-transformed linear pool (BLP)

# Functions -------------------------------------------------------------------
wrapper_TLP <- function(Y, means, sds, weights, eval = TRUE, 
                        plot = FALSE, varPIT = FALSE){
  if(any(weights > 1) || any(weights < 0)) return(-1e8)
  
  weights <- weights/sum(weights)
  ll <- log(dnorm(Y, mean = means, sd = sds) %*% weights) # log-loss
  PIT <- pnorm(Y, mean = means, sd = sds) %*% weights
  
  if(plot){
    hist(PIT, breaks = 0:10/10, col = grey(0.5), freq = FALSE, 
         ylim = c(0, 1.3), main = "TLP")
    abline( h = 1, lty = 2)
  }
  
  if(varPIT) return(var(PIT))
  if(eval) return(sum(ll))
  else return(ll)
}

wrapper_SLP <- function(Y, means, sds, pars, eval = TRUE, 
                        plot = FALSE, varPIT = FALSE){
  con     <- pars[1]
  weights <- pars[-1]
  
  if(con <= 0) return(-1e8)
  if(any(weights > 1) || any(weights < 0)) return(-1e8)
  
  weights <- weights/sum(weights)
  means_SLP <- (matrix(rep(Y, ncol(means)), ncol = ncol(means)) - means)/con
  ll <- log(1/con * dnorm(means_SLP, mean = 0, sd = sds) %*% weights)
  PIT <- pnorm(means_SLP, mean = 0, sd = sds) %*% weights
  
  if(plot){
    hist(PIT, breaks = 0:10/10, col = grey(0.5), freq = FALSE, 
         ylim = c(0, 1.3), main = "SLP")
    abline( h = 1, lty = 2)
  }
  
  if(varPIT) return(var(PIT))
  if(eval) return(sum(ll))
  else return(ll)
}

wrapper_BLP <- function(Y, means, sds, pars, eval = TRUE, 
                        plot = FALSE, varPIT = FALSE){
  ab     <- pars[1:2]
  weights <- pars[-c(1,2)]
  
  if(any(ab <= 0)) return(-1e8)
  if(any(weights > 1) || any(weights < 0)) return(-1e8)
  
  weights <- weights/sum(weights)
  g      <- dnorm(Y, mean = means, sd = sds) %*% weights
  g_beta <- dbeta(pnorm(Y, mean = means, sd = sds) %*% weights, 
                  shape1 = ab[1], shape2 = ab[2])
  ll     <- log(g) + log(g_beta)
  PIT <- pbeta(pnorm(Y, mean = means, sd = sds) %*% weights,
               shape1 = ab[1], shape2 = ab[2])
  
  if(plot){
    hist(PIT, breaks = 0:10/10, col = grey(0.5), freq = FALSE, 
         ylim = c(0, 1.3), main = "BLP")
    abline( h = 1, lty = 2)
  }
  
  if(varPIT) return(var(PIT))
  if(eval) return(sum(ll))
  else return(ll)
}

# Loglikelihood values of a normal distribution
ll_normal <- function(Y, mu, sd){
  ll <- log(dnorm(Y, mean = mu, sd = sd))
  return(ll)
}

# PIT values of a normal distribution
PIT_normal <- function(Y, mu, sd, plot = FALSE, name){
  PIT <- pnorm(Y, mean = mu, sd = sd)
  if(plot){
    hist(PIT, breaks = 0:10/10, col = grey(0.5), freq = FALSE, ylim = c(0, 1.3), 
         main = paste0("Density Forecast", name))
    abline( h = 1, lty = 2)
  }
  return(var(PIT))
}

# Simulation setup ------------------------------------------------------------
n <- 1e5
coefs <- c(a0 = 1, a1 = 1, a2 = 1, a3 = 1.1)
vars  <- matrix(rnorm(n = n*4), nrow = n, 
                dimnames = list(NULL, c("x0", "x1", "x2", "x3")))
Y <- vars %*% coefs + rnorm(n = n)

means <- sds <- matrix(NA, nrow = length(Y), ncol = 3)
for(i in 1:ncol(means)){
  ind <- 1:4 %in% c(1, i+1)
  means[,i]  <- vars[, ind] %*% coefs[ind]
  sds[,i]    <- sqrt(1 + sum(coefs[!ind]^2))
}

forecast_names <- c("f1", "f2", "f3", "TLP", "SLP", "BLP")
ind_est <- c(rep(TRUE, n/2), rep(FALSE, n/2))

# TLP (Traditional linear pool) combination -----------------------------------
# Simple linear combination of forecasts
weights_TLP <- c(0.3, 0.3, 0.4)

# Estimate weights for TLP
while(TRUE){
  est <- optim(
    par     = weights_TLP,
    fn      = wrapper_TLP,
    Y       = Y[ind_est],
    means   = means[ind_est, ],
    sds     = sds[ind_est, ],
    method  = "BFGS",
    control = list(fnscale = -1, trace = TRUE)
  )
  weights_TLP <- est$par/sum(est$par)
  if(abs(sum(est$par) - 1) < 0.01) break
}
round(weights_TLP, 3)

# SLP (Spread-adjusted linear pool) combination -------------------------------
weights_SLP <- c(0.3, 0.3, 0.4)
con         <- 1
pars_SLP    <- c(con, weights_SLP)

# Estimate weights and c (= con) for SLP
while(TRUE){
  est <- optim(
    par     = pars_SLP,
    fn      = wrapper_SLP,
    Y       = Y[ind_est],
    means   = means[ind_est, ],
    sds     = sds[ind_est, ],
    method  = "BFGS",
    control = list(fnscale = -1, trace = TRUE)
  )
  con         <- est$par[1]
  weights_SLP <- est$par[-1]/sum(est$par[-1])
  pars_SLP    <- c(con, weights_SLP)
  if(abs(sum(est$par[-1]) - 1) < 0.01) break
}
round(weights_SLP, 3); round(con, 3)

# BLP (Beta-transformed linear pool) combination ------------------------------
weights_BLP <- c(0.3, 0.3, 0.4)
ab          <- c(1,1)
pars_BLP    <- c(ab, weights_BLP)

# Estimate weights for BLP
while(TRUE){
  est <- optim(
    par     = pars_BLP,
    fn      = wrapper_BLP,
    Y       = Y[ind_est],
    means   = means[ind_est, ],
    sds     = sds[ind_est, ],
    method  = "BFGS",
    control = list(fnscale = -1, trace = TRUE)
  )
  ab          <- est$par[1:2]
  weights_BLP <- est$par[-c(1,2)]/sum(est$par[-c(1,2)])
  pars_BLP    <- c(ab, weights_BLP)
  if(abs(sum(est$par[-c(1,2)]) - 1) < 0.01) break
}
round(weights_BLP, 3); round(ab, 3)

# Evaluation ------------------------------------------------------------------
# Parameter values
table <- matrix(NA, nrow = 3, ncol = 6, 
                dimnames = list(forecast_names[4:6], 
                                c("w1", "w2", "w3", "c", "alpha", "beta")))
table[1,] <- c(weights_TLP, rep(NA, 3))
table[2,] <- c(pars_SLP[-1], pars_SLP[1], rep(NA, 2))
table[3,] <- c(pars_BLP[-c(1,2)], NA, pars_BLP[1:2])

# Overview over estimated parameters
# NAs denote parameters that are not part of the corresponding model
round(table, 3)

# PIT histograms and var(PIT) 
par(mfrow = c(2,3))
vPIT <- rep(NA, 6); names(vPIT) <- forecast_names
for(i in 1:3) vPIT[i] <- PIT_normal(Y = Y[!ind_est], mu = means[!ind_est ,i], 
                                    sd = sds[!ind_est ,i], plot = TRUE, name = i)
vPIT[4] = wrapper_TLP(Y[!ind_est], means = means[!ind_est,], sds = sds[!ind_est,], 
                      weights = weights_TLP, varPIT = TRUE, plot = TRUE)
vPIT[5] = wrapper_SLP(Y[!ind_est], means = means[!ind_est,], sds = sds[!ind_est,], 
                      pars = pars_SLP, varPIT = TRUE, plot = TRUE)
vPIT[6] = wrapper_BLP(Y[!ind_est], means = means[!ind_est,], sds = sds[!ind_est,],
                      pars = pars_BLP, varPIT = TRUE, plot = TRUE)

# Variance of PIT values
# For calibrated forecasts at 1/12 = 0.083...
# (i.e., variance of standard uniform distribution)
round(vPIT, 3)

# Mean log score
# LS(f,y) = -log(f(y))
mls <- matrix(NA, nrow = 7, ncol = 2, dimnames = list(c(forecast_names, "Optimal"), 
                                                      c("Training", "Test")))

for(j in 1:2){
  ind <- if(j == 1) ind_est else !ind_est
  for(i in 1:3) mls[i, j]  <- -mean(ll_normal(Y = Y[ind,], mu = means[ind, i], 
                                              sd = sds[ind, i]))
  mls[4, j] <- - mean(wrapper_TLP(Y = Y[ind], means = means[ind, ], 
                                  sds = sds[ind, ], weights = weights_TLP, eval = FALSE))
  mls[5, j] <- - mean(wrapper_SLP(Y = Y[ind], means = means[ind, ], 
                                  sds = sds[ind, ], pars = pars_SLP, eval = FALSE))
  mls[6, j] <- - mean(wrapper_BLP(Y = Y[ind], means = means[ind, ], 
                                  sds = sds[ind, ], pars = pars_BLP, eval = FALSE))
  mls[7, j]  <- -mean(ll_normal(Y = Y[ind,], mu = (vars %*% coefs)[ind, 1], 
                                sd = rep(1, sum(ind))))
}

# Mean log scores over the training and the test sample
round(mls, 3)
