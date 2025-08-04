# set your working directory using:
# mywd <- "C:/....."
# setwd(mywd)

#### load 2003 data
# speed data is in miles per hour
# directional data is in clockwise degrees, where 0 indicates north 
# (dir <= 180 means easterly winds, dir > 180 means westerly winds)
vs.data <- matrix(scan("Vansycle03.hr.dat",sep=""), ncol=4, byrow=T)
kw.data <- matrix(scan("Kennewick03.hr.dat",sep=""), ncol=4, byrow=T)
gh.data <- matrix(scan("Goodnoe_Hills03.hr.dat",sep=""), ncol=4, byrow=T)

# dates
dates <- as.Date("2002-12-31") + vs.data[, 1]
# hours
hr <- as.integer(vs.data[, 2])
# converts from miles per hour to meters per second 
const <- 1609/3600
# station names repeated by the amount of hours in a year
station.names <- c("VS", "KW", "GH")
station <- factor(rep(station.names, each = 365*24), levels = station.names)

## Location data
# Vansycle
vs.data <- data.frame(date = dates, hr = hr,
                      speed = vs.data[, 3] * const, dir = vs.data[, 4])
# Kennewick
kw.data <- data.frame(date = dates, hr = hr,
                      speed = kw.data[, 3] * const, dir = kw.data[, 4])
# Goodnoe Hills
gh.data <- data.frame(date = dates, hr = hr,
                      speed = gh.data[, 3] * const, dir = gh.data[, 4])

## Variable data
# speed
spd.data <- data.frame(date = dates, hr = hr,
                       VS = vs.data$speed, KW = kw.data$speed, GH = gh.data$speed)
# direction
dir.data <- data.frame(date = dates, hr = hr,
                       VS = vs.data$dir, KW = kw.data$dir, GH = gh.data$dir)

## Complete data
all.data <- data.frame(station = station, date = dates, hr = hr,
                       speed = c(spd.data$VS, spd.data$KW, spd.data$GH),
                       dir = c(dir.data$VS, dir.data$KW, dir.data$GH))
head(all.data)
tail(all.data)
summary(all.data)
str(all.data)

d1 <- all.data[station == "VS", -1]
identical(d1, vs.data)

# a)
#### Histogram of wind speed (Figure 1.5 right)
hist(vs.data$speed, breaks = 0:30)

### histograms and rose diagrams
# install.packages("CircStats")
library(CircStats)
# ADJUSTMENT FROM clock-wise degree notation with 0 corresponding to north
#            TO counter-clock-wise radian notation with 0 corresponding to east 
#               (necessary for rose.diag)
adjustDir <- function(dir) (450 - dir[!is.na(dir)]) * 2 * pi / 360
par(mfrow = c(1, 2))
bins <- 18
hist(vs.data$dir, breaks = c(0, (1:bins-0.5)/bins * 360, 360))
rose.diag(adjustDir(vs.data$dir), bins = bins, prop = 1.75)

### plot wind speed for certain time periods (Figure 1.3)
time.period <- which(dates >= as.Date("2003-06-28") &
                       dates <= as.Date("2003-07-04") )
speedByDay <- function(time.period) {
  time.data <- ts(spd.data[time.period, c("VS", "KW", "GH")],
                  freq = 24, start = 0)
  plot(time.data, ylab = "Wind Speed", xlab = "Daily Index",
       plot.type = "single", type="l", col=c("green", "orange", "red"), 
       lty = c(1, 1, 1))
  legend("topleft", legend = c("VS", "KW", "GH"),
         col = c("green", "orange", "red"), lty = c(1, 1, 1))
}
par(mfrow = c(1, 1))
speedByDay(time.period)

### auto and cross correlation functions
acf(spd.data[c("VS", "KW", "GH")], lag = 48, na.action = na.pass,
    ylim = c(-0.2,1), cex = 1.5, xlab = "", ylab = "")

### boxplots (Figure 1.4; the original figure is for August-December 2002)
forecast.period <- which(dates >= as.Date("2003-08-01"))
time.period <- forecast.period - 2
gh.regime <- factor(ifelse(gh.data$dir[time.period] > 180,
                           "Westerly", "Easterly"),
                    levels = c("Westerly", "Easterly"))
vs.regime <- factor(ifelse(vs.data$dir[time.period] > 180,
                           "Westerly", "Easterly"),
                    levels = c("Westerly", "Easterly"))
par(mfrow=c(1, 2))
boxplot(vs.data$speed[forecast.period] ~ gh.regime, main = "Goodnoe Hills",
        xlab = "", ylab = "",range = 0,col = NA)
boxplot(vs.data$speed[forecast.period] ~ vs.regime, main = "Vansycle",
        xlab = "", ylab = "", range = 0,col = NA)

#### diurnal component (Figure 1.5 left)
time.period.warm <- dates >= as.Date("2003-04-01") &
  dates <= as.Date("2003-09-30")
time.period.cold <- dates <= as.Date("2003-03-31") |
  dates >= as.Date("2003-10-01")
diurnal <- function(time.period, col) {
  average <- sapply(0:23, function(hour) {
    mean(vs.data$speed[time.period & vs.data$hr == hour], na.rm=TRUE)
  })
  p <- 2*pi*(0:23)/24
  fit.lm <- lm(average ~ cos(p) + sin(p) + cos(2*p) + sin(2*p))
  plot(average, ylim = c(5, 11), xlab = "Daily Index", ylab = "", col=col)
  lines(fit.lm$fitted, col=col)
}
par(mfrow = c(1, 1))
diurnal(time.period.warm, "red")
par(new = TRUE)
diurnal(time.period.cold, "blue")

# b)
future.period <- which(dates >= as.Date("2003-09-01"))
VS_correlation <- function(lag, station.data) {
  station.regime <- factor(
    ifelse(station.data$dir[future.period - 2 - lag] > 180,
           "Westerly", "Easterly"), levels = c("Westerly", "Easterly"))
  combined.data <- data.frame(future = vs.data$speed[future.period],
                              past = station.data$speed[future.period-2-lag])
  round(c(cor(subset(combined.data, station.regime == "Westerly"),
              use="pairwise.complete.obs")[2],
          cor(subset(combined.data, station.regime == "Easterly"),
              use="pairwise.complete.obs")[2]), 2)
}
matrix(c(sapply(0:2, VS_correlation, vs.data), 
         sapply(0:2, VS_correlation, kw.data),
         sapply(0:2, VS_correlation, gh.data)), nrow = 2,
       dimnames = list(c("West", "East"),
                       c(expression(V[t]), expression(V[t-1]), expression(V[t-2]),
                         expression(K[t]), expression(K[t-1]), expression(K[t-2]),
                         expression(G[t]), expression(G[t-1]), expression(G[t-2]))))

# c)
Sys.setlocale("LC_TIME", "English")
evaluation_months <- c("May", "June", "July", "August",
                         "September", "October", "November", "Overall")
MAE_persistence <- function(evaluation_month) {
  if (evaluation_month == "Overall") {
    future.period <- which((dates >= as.Date("2003-05-01")) &
                             (dates <= as.Date("2003-11-30")))
  }
  else future.period <- which(months(dates) == evaluation_month)
  
  round(mean(abs(vs.data$speed[future.period]-vs.data$speed[future.period-2]),
             na.rm=TRUE), 2)
}
sapply(evaluation_months, MAE_persistence)

# d)
future.period <- which((dates >= as.Date("2003-05-01")) &
                         (dates <= as.Date("2003-11-30")))

K1 <- 1:72
K2 <- seq(9, 69, 10)

mae <- sapply(K1, function(k) {
  mean(sapply(future.period, function(ind) {
    ensemble <- vs.data$speed[ind - 2 - 0:(k-1)]
    abs(vs.data$speed[ind] - median(ensemble))
  }))
})
coverage <- sapply(K2, function(k) {
  mean(sapply(future.period, function(ind) {
    ensemble <- vs.data$speed[ind - 2 - 0:(k-1)]
    cent.pred.int <- sort(ensemble)[quantile(0:(k+1), c(.1, .9))]
    vs.data$speed[ind] >= cent.pred.int[1] &
      vs.data$speed[ind] <= cent.pred.int[2]}))
})
width <- sapply(K2, function(k) {
  mean(sapply(future.period, function(ind) {
    ensemble <- vs.data$speed[ind - 2 - 0:(k-1)]
    cent.pred.int <- sort(ensemble)[quantile(0:(k+1), c(.1, .9))]
    cent.pred.int[2] - cent.pred.int[1]
  }))
})

matrix(round(mae, 2), nrow = 1, dimnames = list(c("MAE"), c(K1)))
matrix(round(c(coverage, width), 2), nrow=2, byrow=T,
       dimnames = list(c("coverage", "width"), c(K2)))

plot(K1, mae, type="l", xlab = "k", ylab ="", main = "MAE")
plot(K2, coverage, type="l", xlab = "k", ylab ="", main = "Empirical coverage")
plot(K2, width, type="l", xlab = "k", ylab ="", main = "Average width")
