# Plots for Problem 2 (Set 1)

# c)
dens_splitnorm <- function(sd1, sd2, mu = 0) {
  return(function(x) ifelse(x <= mu,
                            2*sd1/(sd1+sd2)*dnorm(x, mu, sd1), 
                            2*sd2/(sd1+sd2)*dnorm(x, mu, sd2)))
}

library(RColorBrewer) # Provides color palettes through brewer.pal()
# display.brewer.all() # Shows all available color palettes

# Choice of sigma_2
sd2_vec <- c(0.5, 1, 2, 3)

colors <- brewer.pal(length(sd2_vec), "Set2")

# # Create PDF
# pdf(file = paste0(getwd(), "/plot_skew_dens.pdf"),
#     height = 10,
#     width = 15,
#     pointsize = 25)

plot(NA, xlim = c(-5,10), ylim = c(0,0.55),
     xlab = "x", ylab = "f(x)", lwd = 3)
for(i in 1:length(sd2_vec)){
  plot(dens_splitnorm(sd1 = 1, sd2 = sd2_vec[i]),
       xlim = c(-5,10), col = colors[i], add = TRUE,
       lwd = 3)
}
abline(v = 0, lty = 2, lwd = 3, col = "lightgrey")
legend("topright",
       legend = paste0("sigma_2 = ", sd2_vec),
       lty = 1,col = colors, lwd = 3)

# # End PDF
# dev.off()
