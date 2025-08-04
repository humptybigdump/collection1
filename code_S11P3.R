# Set your working directory using
# setwd("C:/.../.../...")
# or make sure to put the files containing the data in the default directory
# getwd()

# Load data
data = read.csv("spi_matches.csv")
# Delete matches with missing results
data = data[!is.na(data$score1),]

# Extract relevant information
obs = ifelse(data$score1 > data$score2,1,
                 ifelse(data$score1 == data$score2,2,3))
pred = cbind(p1 = data$prob1,p2 = data$probtie,p3 = data$prob2)

cdf_pred = function(y,p = pred){
  n = nrow(p)
  m = ncol(p)
  rowSums(p*(matrix(rep(1:m,each = n),ncol = m) <= y))
} 

# Calculate PIT and plot PIT-histogram
rand_PIT = function(p,y){
  n = length(y)
  u = runif(n)
  PIT_values = u*p[cbind(1:n,y)] + cdf_pred(y-1)
  return(PIT_values)
}
z = rand_PIT(pred,obs)
hist(z, freq = FALSE, ylim = c(0,2), col = "lightgrey")
abline(h = 1, lty = 2)

# Install the CalSim-package using
# install.packages("CalSim")
# Load the package
library(CalSim)

calsim = calibration_simplex(p1 = pred[,1],
                             p3 = pred[,3],
                             obs = obs)
plot(calsim, use_pvals = TRUE, main = "")

# Calibration simplex with more bins (i.e., using a finer tessellation)
calsim19 = calibration_simplex(n=19,        # number of bins per side of simplex
                            p1 = pred[,1],
                            p3 = pred[,3],
                            obs = obs)
plot(calsim19, use_pvals = TRUE,main = "")

# Brier score for m category forecasts
brier = function(p,y){
  n = nrow(p)
  scores = 1 - 2*p[cbind(1:n,y)] + rowSums(p^2)
  return(scores)
}

# RPS for m category forecasts
rps = function(p,y){
  m = ncol(p)
  scores = rowSums(sapply(1:(m-1), function(k) (cdf_pred(k,p = p) - ifelse(y <= k,1,0))^2))
  return(scores/(m-1))
}

meanBrier = mean(brier(pred,obs))
meanRPS = mean(rps(pred,obs))
meanRPS
meanBrier

# Climatological forecast
climo = table(obs)/length(obs)
climo
pred_climo = matrix(rep(climo,each = length(obs)),ncol=3)

meanBrier_climo = mean(brier(pred_climo,obs))
meanRPS_climo = mean(rps(pred_climo,obs))
meanBrier_climo
meanRPS_climo

# Skill score: Improvement of forecast relative to the climatology
# Note: Skill scores can only be calculated this way if the best score is 0.
skill_score = function(score,score_climo) 1 - score/score_climo             

RPSS = skill_score(meanRPS,meanRPS_climo)
BrierSS = skill_score(meanBrier,meanBrier_climo)
RPSS
BrierSS

