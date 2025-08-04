# Solution to Problem 3 (Set 1)

# b)
dens_splitnorm = function(mu, m, var) {
  c = (m-mu)*sqrt(pi/2)
  sd1 = -c/2 + sqrt(var - (3/4 - 2/pi)*c^2)
  sd2 = c + sd1
  return(function(x) ifelse(x<=mu,
                            2*sd1/(sd1+sd2)*dnorm(x, mu, sd1), 
                            2*sd2/(sd1+sd2)*dnorm(x, mu, sd2)))
}

# c)
library(RColorBrewer) # Provides color palettes through brewer.pal()
# display.brewer.all() # Shows all available color palettes
colors = brewer.pal(5, "Set2")
param = matrix(c(2.31, 3.78, 4.80, 7.03, 9.13,
                 2.31, 3.78, 4.80, 7.05, 9.13,
                 1.68, 1.55, 1.35, 1.01, 0.69), nrow = 3, byrow = TRUE)

# # Create PDF
# pdf(file = paste0(getwd(), "/plot_dens.pdf"),
#     height = 9,
#     width = 15,
#     pointsize = 25)

plot(NA, xlim = c(-2,14), ylim = c(0,0.55),
     xlab = "x", ylab = "f(x)", lwd = 3)
for(i in 1:5){
  plot(do.call(dens_splitnorm,as.list(param[,i])),
       xlim = c(-2,14), col = colors[i], add = TRUE,
       lwd = 3)
}
abline(v = 9.2, lwd = 3)
legend("topright",
       legend = c("May 2021", "Aug 2021", "Nov 2021",
                  "Feb 2022", "May 2022", "observed"),
       lty = 1,col = c(colors,"black"), lwd = 3)

# # End PDF
# dev.off()



## Values from 2010-2011
param = matrix(c(0.88, 1.70, 2.97, 3.55, 4.08,
                 1.08, 1.80, 3.13, 3.61, 4.13,
                 1.19, 1.14, 1.11, 0.88, 0.61), nrow = 3, byrow = TRUE)
plot(NA, xlim = c(-2, 8), ylim = c(0, 0.55), 
     xlab = "x", ylab = "f(x)", lwd = 3)
for(i in 1:5){
  plot(do.call(dens_splitnorm, as.list(param[,i])),
       xlim = c(-2, 8), col = colors[i], add = TRUE, lwd = 3)
}
abline(v = 4.1, lwd = 3)
legend("topright",
       legend = c("Feb 2010", "May 2010", "Aug 2010",
                  "Nov 2010", "Feb 2011", "observed"),
       lty = 1, col = c(colors, "black"), lwd = 3)
