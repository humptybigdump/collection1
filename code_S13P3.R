load(file = "data_S13P3.rda") # contains data.frame 'dataset'
head(dataset)

# Brier and logarithmic scores
brier_score = function(x,y) (x-y)^2
log_score = function(x,y) ifelse(y == 1,-log(x),-log(1-x))

mean_brier = sapply(1:3, function(i) mean(brier_score(dataset[,i],dataset$y)))
mean_log = sapply(1:3, function(i) mean(log_score(dataset[,i],dataset$y)))

cbind(mean_brier,mean_log)

# CORP reliability diagrams and score decomposition
# install.packages("reliabilitydiag")
library(reliabilitydiag)

reldiag1 = reliabilitydiag(y=dataset$y, x=dataset$x1)
reldiag2 = reliabilitydiag(y=dataset$y, x=dataset$x2)
reldiag3 = reliabilitydiag(y=dataset$y, x=dataset$x3)

plot(reldiag1)
plot(reldiag2)
plot(reldiag3)

rbind(summary(reldiag1),summary(reldiag2),summary(reldiag3))

# ROC curves
# install.packages("pROC")
library(pROC)

par(mfrow = c(1,1), pty = "s")

roc1 = roc(dataset$y,dataset$x1)
roc2 = roc(dataset$y,dataset$x2)
roc3 = roc(dataset$y,dataset$x3)

plot(roc1)
plot(roc2,add = TRUE,col = "blue")
plot(roc3,add = TRUE,col = "red")

legend("bottomright",legend = c(expression(x[1]),expression(x[2]),
                                expression(x[3])),
       col = c("black","blue","red"),lwd = 2)

cbind(roc1$auc,roc2$auc,roc3$auc)

# Murphy diagram
# Use 'remotes' package to install a package from GitHub
# install.packages("remotes")
# remotes::install_github("aijordan/murphydiagram2")
library(murphydiagram2)

murphy1 = murphydiag(dataset[,1:3],y = dataset$y,type = "prob")

plot(murphy1,col = c("black","blue","red"),lty = 1)
legend("bottom",legend = c(expression(x[1]),expression(x[2]),
                                expression(x[3])),
       col = c("black","blue","red"),lwd = 2)
