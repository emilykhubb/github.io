#### HW 1 ####
data <- read.csv("kingCountyHouses.csv",header = TRUE)
data

#### a ####
#Examining sqft individually:
a <- data$sqft
summary(a)
hist(a,xlab = "Squarefootage", main = "Histogram + Density of Sqft",ylim = c(0, 0.0005), probability = TRUE, breaks = 25)
lines(density(a))
#Similar to the price distribution, there are a few outliers of homes with a lot more squarefootage. 
#The median is a better descriptor of the average home.
boxplot(a, ylab = "House Sqft", xlab = "All Houses", main = "Boxplot of House Sqft")

#Examining price individually: 
b <- data$price
summary(b)
hist(b, xlab = "Price", ylim = c(0, 0.0000020), main = "Histogram + Density of Price", probability = TRUE, breaks = 50)
lines(density(b))
#It is heavily skewed to the right because of a few extremely expensive homes.
#The median is the best method of measuring central tendency.
boxplot(b, ylab = "House Prices", xlab = "All Houses", main = "Boxplot of House Prices")
#Similar to the Histogram and Density curve, this box plot shows many extreme outliers.

##Examining both sqft and price in relation to the other:
scatter.smooth(a,b, ylab = "Price", xlab = "Sqft", main = "Sqft ~ Price")
#From looking at these two data sets, it seems that a linear model might work very well. 
#Especially if the data set's extreme values were trimmed a bit.

#### b MODEL 1 ####
?lm
linearMod <- lm(b~a)
linearMod
#Intercept = -43866.0 Slope Coefficient = 280.8
#Formula: Y = -43866.0 + 280.8X + E
#With every 1 unit increase in sqft, the price is raised by 280.8
summary(linearMod)
#The P-value is well below the comparison of alpha at 5%. 
#This tells us that sqft has a high correlation with price.
#Also the R^2 is giving a slight indication that the model could give us some valuable insights.
#The slope coefficient, B, is saying with every 1 unit increase in squarefootage, 
#the price is raised $280.80. 


##Checking for normality of residuals (which will apply to the normality of the response variable).
install.packages("nortest")
library(nortest)

linearMod$residuals
lillie.test(linearMod$residuals)
#P-value is well below 5% meaning that we reject the null. 
#In this case, it means that the residuals vary significantly from normality.
#It does not mmeet the normality assumption.
#AKA, as of right now, this model can not be used on other data.

##Checking for constant variation
mean(linearMod$residuals)
par(mfrow=c(2,2))
plot(linearMod)
#The Residuals vs Fitted plot shows an increasing variation. This means that the assumption for 
#constant variation is not met.
#The Q-Q plot matches the result of the lillie.test- not normal.
#The plot indicates heavy-tails/outliers. This means it is not normal.

##Checking for normality of residuals and independence
#The lillie.test told us that the residuals are not normal.

acf(linearMod$residuals)
#The acf function tells us that the residuals are independent.



##Checking for continuous response variable
class(data$price)
#The outcome of this function is "numeric" which most likely indicates a continuous variable. 

## Overall, the assumptions of normality, independence of residuals, and constant variation
# are unmet, met, and unmet, respectively.

#### c MODEL 2 ####
c <-log(data$price)
summary(c)
hist(c, xlab = "Log Price", main = "Histogram + Density of Log Price", probability = TRUE, breaks = 50)
lines(density(c))

#compared to the histogram of the regular price, this one follows a much more bell curve shape
#implying a normality that we didn't see in the regular price.

linearMod.1 <- lm(c~a)
linearMod.1
#Y= 1.222e+01 + 3.989e-04x + E
summary(linearMod.1)
#Similarly to regaular price and sqft, the coefficient adds helpful information to the response variable.
#The information lost in the model actually increased. Instead of capturing 49.28% of information, as the last did,
#it captured a percent less information, 48.35%

#### d #### 
#When sqft increases by 1, the logprice increases by 0.0004.

#### e ####
#Using this logic from the notes: if y is log-transformed, one simply interprets
#e^beta instead of just beta.

#Therefore, when square footage increases by 1, the response variable Y, price, 
#will increase by e^0.0004

#Without a log transformation, the price data is heavily skewed to the right. This means 
#that a few extreme values shift the model dramatically. After using the log transformation,
#the extreme values are shrunkated and this allows for a more normal distribution. This is
#visualized in the histogram and desnity plot of price versus logprice.

#### f ####
##Checking for normality of residuals (which will apply to the normality of the response variable).
install.packages("nortest")
library(nortest)

linearMod.1$residuals
lillie.test(linearMod.1$residuals)
#P-value is well below 5% meaning that we reject the null. 
#In this case, it means that the residuals vary significantly from normality.
#The same can be applied to the normality of the response variable. Therefore, Y is not normal.
#AKA, as of right now, this model can not be used on other data.

##Checking for constant variation
mean(linearMod.1$residuals)
par(mfrow=c(2,2))
plot(linearMod.1)
#The Residuals vs Fitted plot shows a fairly constant variation.The bulk of the residuals have a pretty even variation.
#Once it nears the end, the residuals begin to show a more dynamic variation, but I would argue that the assumption
#for constant variation is mostly met. This is different compared to our earlier graph with regular prices.
#The Q-Q plot matches the result of the lillie.test- not normal. The bulk of the residuals fall within normal range,
#however, the plot indicates heavy-tails/outliers. This means it is not normal.


##Checking for normality of residuals and independence
#The lillie.test told us that the residuals are not normal.

acf(linearMod.1$residuals)
#The acf function tells us that the residuals are independent.


##Checking for continuous response variable

## Overall, the assumptions of normality, independence of residuals, and constant variation
# are unmet, met, and met, respectively.



#### g MODEL 3 ####
d<- log(data$sqft)
summary(d)
hist(d,xlab = "Squarefootage", main = "Histogram + Density of Log Sqft", probability = TRUE, breaks = 25)
lines(density(d))
#Similar to the log price distribution, taking the natural log gives us a more bell-curve shape.
#This indicates a more normal behavior.
boxplot(d, ylab = "House Sqft", xlab = "All Houses", main = "Boxplot of House Log Sqft")
#Converting the sqft to log helps shrink the effect of the outliers as can be seen when comparing both the 
#histograms and boxplots of the reg vs log sqft.

linearMod.2 <- lm(b~d)
linearMod.2
#Y= -3453773 + 528977x + E
summary(linearMod.2)
#Similarly to regular price and sqft, the coefficient adds helpful information to the response variable according to the F-stat.
#The information lost in the model actually increased. Instead of capturing 49.28% of information like the first model,
#it lost a little over 10% more information, 37.41%.

#### h #### 
#The predicted price change as logsqft changes by 1 would be an increase of $528,977. This is simply
#the normal way of interpreting the linear regression formula.


#### i #### 
#As sqft increases by 1% (log(1.01)), the price increases by 528,977 * log(1.01). This comes
#out to be approximately $5,263.

#### j ####
##Checking for normality of residuals (which will apply to the normality of the response variable).
install.packages("nortest")
library(nortest)

linearMod.2$residuals
lillie.test(linearMod.2$residuals)
#P-value is well below 5% meaning that we reject the null. 
#In this case, it means that the residuals vary significantly from normality.
#The same can be applied to the normality of the response variable. Therefore, Y is not normal.
#AKA, as of right now, this model can not be used on other data.

##Checking for constant variation
mean(linearMod.2$residuals)
par(mfrow=c(2,2))
plot(linearMod.2)
#The Residuals vs Fitted plot shows us that the residuals have an increasing variation. AKA it is not constant.
#The Q-Q plot matches the result of the lillie.test- not normal. The bulk of the residuals up until 2 fall within normal range,
#however, after 2 there is heavy deviation from normal.


##Checking for normality of residuals and independence
#The lillie.test told us that the residuals are not normal.

acf(linearMod.2$residuals)
#The acf function, similar to the other two models, tells us that the residuals are independent.


##Checking for continuous response variable

## Overall, the assumptions of normality, independence of residuals, and constant variation
# are unmet, met, and unmet, respectively.


#### k MODEL 4 ####
##Examining both log(sqft) and log(price) in relation to the other:
scatter.smooth(c,d, ylab = "Log(Price)", xlab = "Log(Sqft)", main = "Log(Sqft) ~ Log(Price)")

linearMod.3 <- lm(d~c)
linearMod.3
summary(linearMod.3)
#Formula: Y = 0.4493 + 0.5442X + E
#This means that for every 1 unit increase in logprice, 
#the logsqft increase by 0.5442.

#### l ####
#This is a log-log transformation model, meaning the coefficient becomes an elasticity.
#This means that, as the covariate increase by 1%, the response variable increases by the
#percentage of the covariate coefficient.

#This means that as price (the explanatory variable), increases by 1%, the sqft (response variable)
#increases by 0.5442%. 

#Since l is asking us about a 1% increase in the response variable, we must invert our slope. 
#AKA 1/0.5442 = 1.837. Now, a 1% increase in sqft will create a 1.837% increase in price.

#### m #### 
install.packages("nortest")
library(nortest)

linearMod.3$residuals
lillie.test(linearMod.3$residuals)
#P-value is well below 5% meaning that we reject the null. 
#In this case, it means that the residuals vary significantly from normality.
#The same can be applied to the normality of the response variable. Therefore, Y is not normal.
#AKA, as of right now, this model can not be used on other data.

##Checking for constant variation
mean(linearMod.3$residuals)
par(mfrow=c(2,2))
plot(linearMod.3)
#The Residuals vs Fitted plot shows an inconsistent variation meaning 
#constant variation assumption is not met.
#The Q-Q plot matches the result of the lillie.test- not normal. The bulk of the residuals fall within normal range,
#however, the plot slowly deviates from normal at the extreme values. This means it is not normal.


##Checking for normality of residuals and independence
#The lillie.test told us that the residuals are not normal.

acf(linearMod.3$residuals)
#The acf function tells us that the residuals are independent.


##Checking for continuous response variable

## Overall, the assumptions of normality, independence of residuals, and constant variation
# are unmet, met, and unmet, respectively.

#### n MODEL 4.adj ####
e <- data$bedrooms
summary(e)
hist(e,xlab = "Bedrooms", main = "Histogram + Density of Bedrooms", xlim = c(0,10), probability = TRUE, breaks = 25)

linearMod.3.2 <- lm(d~c+e)
linearMod.3.2
summary(linearMod.3.2)
#The adjusted R^2 of this model is 0.627. This is a stark jump from the adjusted R^2 of Model 4 of 0.4555.
#By adding in a second covariate, number od bedrooms, we have significantly increased the amount of information 
#that we have gathered from the data.




