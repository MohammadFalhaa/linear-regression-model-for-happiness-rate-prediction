library(reshape2)
library(lattice)
library(ggplot2)
library(readxl)
library(lmtest)
library(MASS)
library(tseries)
library(htmlTable)

my_data <- read_excel("life_ladder.xlsx")
summary(my_data)
boxplot(my_data$Y)
hist(my_data$Y,main='without transformation')
hist(log(my_data$Y),main='Log Transformed')
hist(sqrt(my_data$Y),main='Square Root Transformed')
hist((my_data$Y)^(1/3),main='Cube Root Transformed')
shapiro.test(my_data$Y)
pairs(my_data)
correlation_matrix <- round(cor(my_data),2)
melted_correlation_matrix <- melt(correlation_matrix)
ggplot(data = melted_correlation_matrix, aes(x=Var1, y=Var2, fill=value)) + geom_tile() + geom_text(aes(Var2, Var1, label = value), color = "black", size = 4)
par(mfrow=c(1,1))

head(my_data)
pairs(my_data)
cor(my_data)

model1  <- lm(Y~ ., data=my_data)
summary(model1)

model2 <- lm(Y~ X1 + X2 + X4 +X5 + X6 + X7 + X8 + X9, data=my_data)
summary(model2)

model3 <- lm(Y~ X1 + X2 + X4  + X6 + X7 + X8 + X9, data=my_data)
summary(model3)

model4 <- lm(Y~ X1 + X2 + X4  + X6 + X7  + X9, data=my_data)
summary(model4)
#mse
install.packages("Metrics") 
library("Metrics")
mse(my_data$Y, predict(model4 , my_data)) 
mean(model4$residuals^2) 
htmlTable(summary(model4))
plot(fitted(model4), resid(model4), pch=20)
lines(loess.smooth(fitted(model4), resid(model4)), col="red")
title("Residuals vs. Fitted")
qqnorm(resid(model4), pch=20); qqline(resid(model4))

boxplot(model4$residuals)$out
shapiro.test(model4$residuals)
acf(model4$residuals)
AIC(model4)
hist(resid(model4))
plot(model4)
jarque.bera.test(model4$residuals)
#outliers: 
res.student <- rstudent(model4)
alpha <- 0.05
thershold.student <- 1.95
atypical.rstudent <- (res.student < -thershold.student | res.student > +thershold.student)
ab.student <- my_data[atypical.rstudent ,]
print(ab.student)


plot(my_data$Y,res.student,cex=0.75)
abline(h=-thershold.student)
abline(h=+thershold.student)
abline(h=0)
text(my_data$Y[atypical.rstudent],res.student[atypical.rstudent],rownames(my_data)[atypical.rstudent])

model5 <- lm(Y~  X2 + X4 + X6 + X7 , data=my_data)

summary(model5)

model6 <- lm(Y~  X2 + X4 + X6 , data=my_data)

summary(model6)

plot(fitted(model6), resid(model6), pch=20)
lines(loess.smooth(fitted(model6), resid(model6)), col="red")
title("Residuals vs. Fitted")

qqnorm(resid(model6), pch=20); qqline(resid(model6))

boxplot(model6$residuals)$out
shapiro.test(model6$residuals)
acf(model6$residuals)
AIC(model6)
plot(model6)

model7 <- lm(Y~  X2 + X3 + X4 + X6 , data=my_data)

summary(model7)

plot(fitted(model7), resid(model7), pch=20)
lines(loess.smooth(fitted(model7), resid(model7)), col="red")
title("Residuals vs. Fitted")

qqnorm(resid(model7), pch=20); qqline(resid(model7))

boxplot(model7$residuals)$out
shapiro.test(model7$residuals)
acf(model7$residuals)
AIC(model7)
plot(model7)

model.selection <- stepAIC(model1)
model.selection <- stepAIC(model1,direction = "backward")
model.selection <- stepAIC(model1,direction = "both")


test_data <- read_excel("C:/Users/user/OneDrive/Desktop/multiple regression project//life_ladder test data.xlsx")
#predictions <- model4 %>% predict(test_data)
pred <- predict(model4,newdata=test_data,interval="prediction",level=0.9)
print(pred)
htmlTable(pred)
average_lwr <- sum(pred[,'lwr'])/31
average_upr <- sum(pred[,'upr'])/31
average_upr - average_lwr

predicted_or_not <- (pred[,'fit'] >= pred[,'lwr']) & (pred[,'fit'] < pred[,'upr'])
print(predicted_or_not)


hist(model4$residuals)
