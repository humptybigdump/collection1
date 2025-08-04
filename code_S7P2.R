#####################################################################
# From code_S3P3:

# Load data
load("obsforc.Rdata")

for(i in 1:17){
  if(i == 1) Y <- obsforc[,i]
  if(i > 1){
    # Even column index: mu_i; odd column index: sd_i
    if(i%%2 == 0){
      assign(x = paste0("mu",i/2), value = obsforc[,i])
    }else{
      assign(x = paste0("sd",(i-1)/2), value = obsforc[,i])
    }
  }
}

# Marginal calibration
# Empirical average forecast distributions
Fn <- function(mu, sigma){
  return(function(x) sapply(x,function(x) mean(pnorm(x,mu,sigma))))
}
# Empirical marginal distribution of observations
FnY <- ecdf(x = Y)
# Differences in marginal distribution
par(mfrow = c(2,4))
for(i in 1:8){
  assign(x = paste0("Fn",i), value = Fn(get(paste0("mu",i)),get(paste0("sd",i))))
  plot(x = function(x) get(paste0("Fn",i))(x) - FnY(x), col = "red", main = paste0("F",i),ylab = paste0("Fn",i,"(x) - FnY(x)"),xlim = c(-7,7),ylim = c(-0.1,0.1))
  abline(h = 0,lty = 2,col = "grey")
}
marg = c(T,F,T,T,T,T,F,T)

# Probabilistic calibration
# PIT values
PIT.values <- function(Y, mu, sigma){
  y.norm    <- (Y-mu)/sigma
  PIT.value <- pnorm(y.norm)
  return(PIT.value)
}
# PIT histograms
for(i in 1:8){
  assign(x = paste0("PIT",i), value = PIT.values(Y = Y, 
                                                 mu = get(paste0("mu",i)), sigma = get(paste0("sd",i))))
  hist(get(paste0("PIT",i)), freq = FALSE, col = grey(0.8), 
       main = paste0("PIT",i), xlab = paste0("Forc ",i),
       ylim = c(0, 2 + 3*(i == 1) + 4*(i == 8)))
  abline(h = 1, lty = 2)
}
prob = c(F,F,T,T,T,T,F,F)

# Sharpness + Ranking
# e.g. look at variance (constant for each forecaster!)
sd = rep(NA,8)
for(i in 1:8){
  sd[i] = get(paste0("sd",i))[1]
}
data.frame(marg,prob,sd)
ranking = c(3,5,4,6,1,8,2,7) #exemplary ranking by sharpness subject to calibration
data.frame(marg,prob,sd)[ranking,]

#####################################################################
# From code_S5P2.R

# Evaluation by CRPS
crps.normal <- function(Y, mu, sigma){
  y.norm <- (Y-mu)/sigma
  crps.normalforc <- sigma*(y.norm*(2*pnorm(y.norm)-1)+2*dnorm(y.norm)-1/sqrt(pi))
  return(crps.normalforc)
}
meanCRPS <- rep(NA, 8)
for(i in 1:8){
  meanCRPS[i] <- mean(crps.normal(Y = Y,
                                  mu = get(paste0("mu",i)),
                                  sigma = get(paste0("sd",i))))
}

old_ranks = match(1:8,ranking)
data.frame(marg,prob,sd,meanCRPS,old_ranks)
new_ranking = order(meanCRPS)
data.frame(marg,prob,sd,meanCRPS,old_ranks)[new_ranking,]

#####################################################################
# Toy example illustrating the use of the optim function
# The function optim optimizes a given function based on a set of 
# initial parameters par over some data. 

# Here, the task is to maximize the volume of a cuboid with fixed
# total length of edges equal to 12. Clearly the volume is maximal
# when all edges have equal length, leaving a volume of 1.
# We start with side a = 0.05 of length 0.05, and similarly
# b = 0.05, leaving side c of length (12-4*a-4*b)/4. 
# Then the function to maximize is a*b*c and the parameters we 
# need are a and b.

pars <- c(a = 0.05, b = 0.05)
get.vol <- function(pars){
  c    <- (12-4*pars[1]-4*pars[2])/4
  vol  <- pars[1]*pars[2]*c
  return(vol)
}

# Inital value
get.vol(pars = pars)

# Optimization

# fnscale = -1 is necessary to maximize the volume instead
# of minimizing it
# trace shows the single steps
# If additional data (e.g. training data) are necessary for
# the evaluation of the function, these can be added as 
# additional entry
# e.g. if get.vol <- function(pars, data){...} then one
# would add the line "data = data," to the optimization

est <- optim(
  par = pars,
  fn  = get.vol,
  control = list(fnscale = -1, trace = TRUE)
)

# est contains now the new estimated parameters
# and shows you additional information
print(est)

# Estimated volume is one and parameters very close to one
get.vol(pars = est$par)

#####################################################################
# a-d) Ensemble Postprocessing + Evaluation

# Generate and evaluate the EMOS forecast using CRPS minimization
generate.EMOS.forecast <- function(mu, sigma, obs){
  # a) Emulate ensemble
  # Generate an ensemble of size 5 for given mu and sigma
  generate.ens.from.normal <- function(mu, sigma){
    ensemble <- rnorm(n = 5, mean = mu, sd = sigma)
    return(ensemble)
  }
  # Generate an ensemble for each forecast
  ensforc <- t(apply(cbind(mu, sigma), 1, 
                     function(x) generate.ens.from.normal(mu = x[1], sigma = x[2])))
  varensforc <- apply(ensforc, 1, var)
  
  # b) Training test split
  # Forecast-observation database
  db <- cbind(obs, rep(1, length(obs)), ensforc, varensforc)
  # Training data
  ntr = round(nrow(db) * 0.1,0)
  ind = c(rep(TRUE, ntr),rep(FALSE,nrow(db)-ntr))
  dbtr <- db[ind, ] 
  # Test data
  dbtst <- db[!ind,]
  
  # c) Estimation of the regression coefficients based on the training data
  # Estimate the CRPS based on some forecast-observation pairs in db 
  # and parameters pars
  wrapper.min.crps <- function(db, pars){
    if(any(pars[7:8] < 0)){
        CRPS <- 10^8
    }else{
      ind.a <- grepl("a", names(pars))
      mu     <- db[, 2:(ncol(db)-1)] %*% pars[ind.a]
      sigma2 <- db[, c(2,ncol(db))]^2 %*% pars[!ind.a]
      CRPS <- sum(crps.normal(Y = db[,"obs"], mu = mu, sigma = sqrt(sigma2)))
    }
    return(CRPS)
  }

  # CRPS minimization
  pars <- c(0, rep(0, ncol(ensforc)), 1, 0)
  # pars <- c(0, rep(1/ncol(ensforc), ncol(ensforc)), 0, 1) # Try this!
  names(pars) <- c(paste0("a", 0:ncol(ensforc)), paste0("b", 0:1))
  est <- try(optim(
    par     = pars,
    fn      = wrapper.min.crps, 
    db      = dbtr, 
    gr      = "L-BFGS-B", 
    control = list(trace = FALSE, maxit = 5*10^3)))
  
  print("Parameters: ")
  print(round(est$par[grepl("a", names(est$par))], 4))
  print(round(est$par[grepl("b", names(est$par))], 4))
  print(paste0("optimized mean CRPS (training data) = ",
               round(est$value/length(obs[ind]), 4)))

  # d) Apply to the test data
  mu.cor     <- dbtst[, 2:(ncol(dbtst)-1)] %*% est$par[grepl("a", names(est$par))]
  sigma.cor2 <- dbtst[, c(2,ncol(dbtst))]^2 %*% est$par[grepl("b", names(est$par))]
  sigma.cor  <- sqrt(sigma.cor2)
  # The remaining observations are the test data observations
  Ynew      <- dbtst[,"obs"]
  # Return test set rows
  rows.tst <- which(!ind)
  return(cbind(mu.cor, sigma.cor, Ynew, rows.tst))
}

# Correct uncalibrated forecasts 1,2,7, and 8 and 
# generate a plot for the marginal distribution and PIT histograms
par(mfrow = c(2,4))
for(i in c(1,2,7,8)){
  print(paste0("Forecast ",i))
  # Get the postprocessed mu and sigma parameters and store them as mui.new and sdi.new
  newnormal <- generate.EMOS.forecast(mu = get(paste0("mu",i)), 
                                      sigma = get(paste0("sd",i)), 
                                      obs = Y)
  assign(paste0("mu",i,".new"), newnormal[,1])
  assign(paste0("sd",i,".new"), newnormal[,2])
  Y.tst     <- newnormal[,3]
  i.tst     <- newnormal[,4]
  # Empirical CDF of test observations
  FnY.tst   <- ecdf(x = Y.tst)
  # CRPS
  print(paste0("After postprocessing: mean CRPS (application data) = ",round(mean(
    crps.normal(Y = Y.tst, 
                mu = get(paste0("mu",i,".new")), 
                sigma = get(paste0("sd",i,".new")))), 4)))
  print(paste0("Before postprocessing: mean CRPS (application data) = ",round(mean(
    crps.normal(Y = Y.tst, 
                mu = get(paste0("mu",i))[i.tst], 
                sigma = get(paste0("sd",i))[i.tst])), 4)))
  # Marginal calibration
  assign(x = paste0("Fn",i,".new"), value = Fn(get(paste0("mu",i,".new")),get(paste0("sd",i,".new"))))
  plot(x = function(x) get(paste0("Fn",i,".new"))(x) - FnY.tst(x), col = "red", 
       main = paste0("F",i),ylab = paste0("Fn",i,"(x) - FnY(x)"),xlim = c(-7,7),ylim = c(-0.1,0.1))
  abline(h = 0,lty = 2,col = "grey")
  # Probabilistic calibration
  assign(x = paste0("PIT",i,".new"), value = PIT.values(Y = Y.tst, 
                                                 mu = get(paste0("mu",i,".new")), sigma = get(paste0("sd",i,".new"))))
  hist(get(paste0("PIT",i,".new")), freq = FALSE, col = grey(0.8), 
       main = paste0("PIT",i), xlab = paste0("Forc ",i),
       ylim = c(0, 2))
  abline(h = 1, lty = 2)
}

# e)
# We can characterize all mean predictions in terms of the forecasts 4 and 5:
all(mu1 == mu5 - mu4)
all(mu2 == mu5)
all(mu3 == mu5 + mu4)
all(mu6 == 0)
all(mu7 == mu5 + 0.1)
all(mu8 == -mu5 - mu4)

# Hypothesis Y = mu4 + mu5 + eps
par(mfrow = c(2,2))
# mu4 is normal with mean 0 and variance 0.5
hist(mu4,breaks = 100,freq = FALSE)
plot(function(x) dnorm(x,sd = sqrt(1/2)),xlim = c(-3,3), add = TRUE,col = "blue")
# mu5 is standard normal
hist(mu5,breaks = 100,freq = FALSE)
plot(dnorm,xlim = c(-3,3), add = TRUE,col = "blue")
# eps is standard normal
hist(Y-mu4-mu5,breaks = 100,freq = FALSE)
plot(dnorm,xlim = c(-3,3), add = TRUE,col = "blue")
# Y is normal with mean 0 and variance 2.5
hist(Y,breaks = 100,freq = FALSE)
plot(function(x) dnorm(x,sd = sqrt(2.5)),xlim = c(-3,3), add = TRUE,col = "blue")
