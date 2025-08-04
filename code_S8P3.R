# Data generation
n = 100000
# You may want to use less samples to make the computations run faster:
# n = 10000
sigma = rep(1,n+1)
z = rep(0,n)
for (i in 1:n) {
  z[i] = rnorm(1, mean = 0, sd = sigma[i])
  sigma[i+1] = sqrt(0.2*z[i]^2 + 0.75*sigma[i]^2 + 0.05)
}
sigma = sigma[1:n]
y = z^2

# Forecast generation
predictions = data.frame(pessimist = rep(0.05,n), optimist = rep(5,n),
                         mean = sigma^2, median = qnorm(0.75,0,1)^2*sigma^2)

# Scoring functions
patton = function(b,x,y){
  b = rep(b,length(x))
  scores = ifelse(b == 0, y/x-log(y/x)-1,
                 ifelse(b == 1, y*log(y/x)-y+x,
                        1/(b*(b-1))*(y^b-x^b)-1/(b-1)*x^(b-1)*(y-x)))
  return(sum(scores)/length(x))
}
gpl_power = function(b,x,y){
  b = rep(b,length(x))
  scores = ifelse(b == 0, abs(log(x/y)),
                 abs((x^b-y^b)/b))
  return(sum(scores)/length(x))
}

# Calculate mean scores
b = seq(-0.5,2.5,0.01)
patton_scores = apply(predictions,2,function(x) sapply(b,function(b) patton(b,x,y)))
gpl_power_scores = apply(predictions,2,function(x) sapply(b,function(b) gpl_power(b,x,y)))

# Plot mean scores
par(mfrow = c(1,2))
cols = c("red","green","blue","black")
matplot(b,patton_scores,ylim =c(0,10),type = "l",lty = 1,col = cols,ylab = "mean Patton score")
legend("top",legend = names(predictions),
       col = cols,lty = 1)
matplot(b,gpl_power_scores,ylim =c(0,10),type = "l",lty = 1,col = cols,ylab = "mean GPL power score")
legend("top",legend = names(predictions),
       col = cols,lty = 1)
