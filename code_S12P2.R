library(scoringRules)
library(lubridate)
# Loading Data
load("MUprecip.Rdata")

# Get to know the data
View(precip)
range(precip$init_tm)
hist(precip$obs)
summary(precip$obs)

## Split data for training and testing
# Training data (until October 2021)
training_ind <- which(precip$init_tm < "2021-11-01")
training_set <- precip[training_ind, ]

# Test data (November 2021 - October 2022)
eval_ind <- which(precip$init_tm >= "2021-11-01")
eval_set <- precip[eval_ind, ]

# a)
# Rank histogram
rhist <- function(ensfc, obs, ...) {
  # Adapt for discrete component in zero
  ranks <- apply(ensfc <= obs, 1, sum) - 
    sapply(apply(ensfc == obs, 1, sum), sample, size = 1) + 1
  
  hist(ranks, col = "lightgrey", breaks = 1:41, freq = FALSE)
  abline(h = 1/41, lty = 2)
}

# Histogram on training set
rhist(training_set[,paste0("ens_", 1:40)], training_set$obs)


# b)

## Training EMOS
# Target function that we want to minimize
target_fun <- function(par, ens_mean, ens_var, obs){
  # Ensure positive variance by penalty for negative coefficients
  if(any(par[3:4] < 0)){ return(10^8) }
  
  m <- cbind(1, ens_mean) %*% par[1:2] # mu = a_0 + a_1*ens_mean
  s <- sqrt(cbind(1, ens_var) %*% par[3:4]) # sigma^2 = b_0 + b_1*ens_var
  score <- sum(crps_norm(y = obs, location = m, scale = s))
  return(score)
}

# Calculate ensemble mean and variance within training and test set
training_set[,"ens_mean"] <- apply(training_set[,paste0("ens_", 1:40)], 1, mean)
training_set[,"ens_var"] <- apply(training_set[,paste0("ens_", 1:40)], 1, var)
eval_set[,"ens_mean"] <- apply(eval_set[,paste0("ens_", 1:40)], 1, mean)
eval_set[,"ens_var"] <- apply(eval_set[,paste0("ens_", 1:40)], 1, var)

# Optimization
optim_out <- optim(par = c(1, 1, 1, 1), # starting values
                   fn = target_fun, # objective fct
                   ens_mean = training_set$ens_mean,
                   ens_var = training_set$ens_var,
                   obs = training_set$obs)

optim_out
opt_par <- optim_out$par

# Apply model to evaluation data
eval_mu_norm <- as.vector(cbind(1, eval_set$ens_mean) %*%  opt_par[1:2])
eval_sigma_norm <- as.vector(sqrt(cbind(1, eval_set$ens_var) %*%  opt_par[3:4]))

## Evaluation
# Rank (ensemble) and PIT (EMOS) histograms
par(mfrow = c(1, 2))
rhist(eval_set[,paste0("ens_", 1:40)], eval_set$obs)

# PIT values
PIT_norm <- pnorm(eval_set$obs, eval_mu_norm, eval_sigma_norm)
hist(PIT_norm, breaks = 40, col = "lightgrey", freq = FALSE)
abline(h = 1, lty = 2)

# CRPS
scores <- cbind(ens = crps_sample(eval_set$obs, dat = as.matrix(eval_set[,paste0("ens_", 1:40)])),
                norm = crps_norm(eval_set$obs, location = eval_mu_norm, scale = eval_sigma_norm))
colMeans(scores)


# c)

# The normal distribution assigns some positive probability to negative precipitation 
# and has no point mass in zero, e.g.,
mu = 1
sd = 1
pnorm(0,mu,sd)

# This can be remedied by using a (zero-)censored normal distribution, 
# which only allows for non-negative outcomes and a point mass in zero:

## Training EMOS using censored normal distribution
# Target function that we want to minimize
target_fun_cnorm <- function(par, ens_mean, ens_var, obs){
  # Ensure positive variance by penalty for negative coefficients
  if(any(par[3:4] < 0)){ return(10^8) }
  
  m <- cbind(1, ens_mean) %*% par[1:2] # mu = a + b ensmean
  s <- sqrt(cbind(1, ens_var) %*% par[3:4]) # sigma^2 = b_0 + b_1*ens_var
  score <- sum(crps_cnorm(y = obs, location = m, scale = s,lower = 0))
  return(score)
}

# Optimization
optim_out_cnorm <- optim(par = c(1, 1, 1, 1), # starting values
                         fn = target_fun_cnorm, # objective fct
                         ens_mean = training_set$ens_mean,
                         ens_var = training_set$ens_var,
                         obs = training_set$obs)

optim_out_cnorm
opt_par_cnorm <- optim_out_cnorm$par

# Apply model to evaluation data
eval_mu_cnorm <- as.vector(cbind(1, eval_set$ens_mean) %*%  opt_par_cnorm[1:2])
eval_sigma_cnorm <- sqrt(cbind(1, eval_set$ens_var) %*% opt_par_cnorm[3:4])

## Evaluation
# PIT values
hist(PIT_norm, breaks = 40, col = "lightgrey", freq = FALSE)
abline(h = 1, lty = 2)

# (Randomized) PIT values
PIT_cnorm <- ((eval_set$obs == 0)*runif(nrow(eval_set)) + 
                (eval_set$obs > 0))*pnorm(eval_set$obs, eval_mu_cnorm, eval_sigma_cnorm)
hist(PIT_cnorm, breaks = 40, col = "lightgrey", freq = FALSE, ylim = c(0, 12))
abline(h = 1, lty = 2)


# CRPS
scores <- cbind(ens = crps_sample(eval_set$obs, dat = as.matrix(eval_set[,paste0("ens_", 1:40)])),
                norm = crps_norm(eval_set$obs, mean = eval_mu_norm, sd = eval_sigma_norm),
                cnorm = crps_cnorm(eval_set$obs, location = eval_mu_cnorm, scale = eval_sigma_cnorm, lower = 0))
colMeans(scores)

# d)
# Load package
library(isodistrreg)

# Fit IDR
est_idr <- idr(y = training_set$obs,
               X = data.frame("ens_mean" = training_set$ens_mean)) # X must be a data frame

# Predict IDR
pred_idr <- predict(object = est_idr,
                    data = data.frame("ens_mean" = eval_set$ens_mean))

## Plotting
par(mfrow = c(1,1))
# Choose random samples to plot
i_plot <- sample(1:nrow(eval_set), size = 1)
# i_plot <- 89
# i_plot <- 159

# Plot IDR
plot(pred_idr, index = i_plot, xlim = c(-1, 11), ylim = c(0, 1))

# Add EMOS forecasts
x_plot <- seq(-10, 60, 0.01)
lines(x = x_plot,
      y = pnorm(x_plot, mean = eval_mu_norm[i_plot], sd = eval_sigma_norm[i_plot]),
      col = "red")
lines(x = x_plot,
      y = (x_plot >= 0)*pnorm(x_plot, mean = eval_mu_cnorm[i_plot], sd = eval_sigma_cnorm[i_plot]),
      col = "green")

# Add ensemble members
for(i_ens in 1:40){
  abline(v = eval_set[i_plot, paste0("ens_", i_ens)],
         lty = 2,
         col = "lightgrey")
}

# Add observation
abline(v = eval_set[i_plot, "obs"],
       lty = 2,
       col = "magenta")



## Evaluation
# CRPS
scores <- cbind(scores, idr = crps(predictions = pred_idr,
                                   y = eval_set$obs))
colMeans(scores)

# PIT histograms
par(mfrow = c(1,2))
hist(PIT_cnorm, breaks = 20, col = "lightgrey", freq = FALSE, ylim = c(0, 2.5))
abline(h = 1, lty = 2)

PIT_idr <- pit(predictions = pred_idr,
               y = eval_set$obs)
hist(PIT_idr, breaks = 20, col = "lightgrey", freq = FALSE, ylim = c(0, 2.5))
abline(h = 1, lty = 2)


## Improve IDR predictions by using subagging
# Fit IDR with subagging
sbg_idr <- idrbag(y = training_set$obs,
                  X = data.frame("ens_mean" = training_set$ens_mean),
                  newdata = data.frame("ens_mean" = eval_set$ens_mean),
                  b = 100, # Use 100 subsamples
                  p = 0.5, # Each with half of the original training set size
                  replace = TRUE) # Sampling with replacement

## Plotting
par(mfrow = c(1,1))
# Choose random samples to plot
# i_plot <- sample(1:nrow(eval_set), size = 1)
i_plot <- 89

# Plot IDR
plot(sbg_idr, index = i_plot, xlim = c(-1, 11), ylim = c(0, 1))
# plot(pred_idr, index = i_plot, add = TRUE)

# Add EMOS forecasts
x_plot <- seq(-10, 60, 0.01)
lines(x = x_plot,
      y = pnorm(x_plot, mean = eval_mu_norm[i_plot], sd = eval_sigma_norm[i_plot]),
      col = "green")
lines(x = x_plot,
      y = (x_plot >= 0)*pnorm(x_plot, mean = eval_mu_cnorm[i_plot], sd = eval_sigma_cnorm[i_plot]),
      col = "red")


## Evaluation
# CRPS
scores <- cbind(scores, idr_sbg = crps(predictions = sbg_idr,
                                       y = eval_set$obs))
colMeans(scores)

# PIT histograms
par(mfrow = c(1, 2))
hist(PIT_idr, breaks = 20, col = "lightgrey", freq = FALSE, ylim = c(0, 2.5))
abline(h = 1, lty = 2)

PIT_sbg <- pit(predictions = sbg_idr,
               y = eval_set$obs)
hist(PIT_sbg, breaks = 20, col = "lightgrey", freq = FALSE, ylim = c(0, 2.5))
abline(h = 1, lty = 2)

