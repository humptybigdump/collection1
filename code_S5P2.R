#####################################################################
# From code_S3P3:

# Load data
load("obsforc.Rdata")

# Read out observations and forecasts
Y <- obsforc[,"Y"]
for(i in 1:8){
  assign(x = paste0("mu",i), value = obsforc[,paste0("mu",i)])
  assign(x = paste0("sd",i), value = obsforc[,paste0("sd",i)])
}

# Marginal calibration
# Empirical average forecast distributions
Fn <- function(mu, sigma){
  return(function(x) sapply(x,function(x) mean(pnorm(x,mu,sigma))))
}
# Empirical marginal distribution of observations
FnY <- ecdf(x = Y)

par(mfrow = c(2,4))
# Plotting average of forecast CDFs and empirical CDF
# Differences in marginal distribution
for(i in 1:8){
  assign(x = paste0("Fn",i), value = Fn(get(paste0("mu",i)),get(paste0("sd",i))))
  plot(x = function(x) get(paste0("Fn",i))(x) - FnY(x), col = "red", main = paste0("F",i),
       ylab = paste0("Fn",i,"(x) - FnY(x)"),xlim = c(-7,7),ylim = c(-0.1,0.1))
  abline(h = 0,lty = 2,col = "grey")
}
marg = c(T,F,T,T,
         T,T,F,T)

# PIT values
PIT.values <- function(Y, mu, sigma){
  y.norm    <- (Y-mu)/sigma
  PIT.value <- pnorm(y.norm)
  return(PIT.value)
}

# PIT histograms (Mind the limits of the y-axis!)
for(i in 1:8){
  assign(x = paste0("PIT",i), value = PIT.values(Y = Y, 
                                                 mu = get(paste0("mu",i)), 
                                                 sigma = get(paste0("sd",i))))
  hist(get(paste0("PIT",i)), freq = FALSE, col = grey(0.8), 
       main = paste0("PIT",i), xlab = paste0("Forc ",i),
       ylim = c(0, 2 + 3*(i == 1) + 4*(i == 8)))
  abline(h = 1, lty = 2)
}
prob = c(F,F,T,T,
         T,T,F,F)

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
# New code:

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

# Some observations:
# 2 is underdispersed 5
# 7 is overdispersed and biased 5
# 6 is the climatological forecast
# 8 is a sign-reversed 3







