#### HW 2 ####
data <- read.csv("pizza_delivery.csv",header = TRUE)
data
View(data)
dim(data)
#### 1 Model One ####
m1 <- lm(time~ temperature + branch + day + operator + driver + bill + pizzas + discount_customer, data = data)
m1

summary(m1)

#Using the summary output, it is easy to see the significance of some of these coefficients in predicting pizza delivery time.
#Whenever the covariate is increased by one unit, its corresponding coefficient gives the increase(+) or decrease(-) that will be seen in pizza delivery time.
#There are 5 coefficients that are extremely significant in predicting the response variable: temperature, branchEast, driverDomenico, bill, and number of pizzas.
#According to the p-values (which are also significantly lower than and alpha of 0.05), these variables are important in this linear regression model.
#This is also supported by the p-value result of the F-test. Having such a low p-value indicates that the full model (as compared to the reduced model) is a better predictor for the response variable.
#What this means is that the covariates are important and at least some of them should be kept in the model to allow a more accurate prediction.

#### 2 ####
confint(m1, level = 0.95)  # 95% CI

#These confidence intervals also give us an indication of the most significant variables. All 5 that showed significant p-values have a range that is fully positive or fully negative.
#When a confidence interval includes 0, this means that it is possible for that covariate to have zero affect on the response variable. When ranges do not include zero,
#it can be concluded that 95% of the time, a test will conclude the covariate has an effect on the response, even if it is higher or lower than the defined coefficient value.

#### 3 ####
#Least Squares Estimate of sigma^2 AKA Residual Standard Error is calculated by the ollowing formula:
#Sqrt(Residual sum of squares/degrees of freedom)

#To calculate RSS, we have to square the residuals and then sum them which is produced by the following code:

residuals <- resid(m1) #residuals
RSS <- sum(residuals^2) #squaring residuals and then summing them to produce RSS
RSS


df <- m1$df.residual #retrieve degrees of freedom from the model
df

LSE <- sqrt(RSS / df) #calculating Least Squares Estimate (LSE)
LSE

#This gives us 5.373 which matches the Residual Standard Error that the summary output gave us.

#### 4 ####
#From the summary information, we see that R-squared is 0.3178 and Ajusted R-squared is 0.3085.
#These R-squared values tell us a lot about the accuracy of the current model. With an adjusted R-squared of 0.3085,
#it is reasonable to say that we are missing out on a lot of information that this data could be giving us. 
#We are losing almost 70 percent accuracy with this current model. This encourages me to rework the model to find the 
#covariates that will give us the highest amount of prediction precision. 

#### 5 ####
library(MASS)
step <- stepAIC(m1, direction="backward")
step$anova 

#According to AIC, the best model includes: temperature, branch, day, driver, bill, and number of pizzas.

#### 6 Model Two ####
m2 <- lm(time~ temperature + branch + day + driver + bill + pizzas, data = data)
m2

summary(m2)

#The adjusted  R-squared barely changed in Model Two compared  to Model One. it only increased by 0.0007.
#That is minuscule  and indicates the same level of accuracy that is lost in this model.
#I think that to get a model with a greater Adjusted  R-squared, you would have to specify which driver and which branch to include in your prediction.

#### 7 Checking Assumptions ####
###Checking for normality of residuals (which will apply to the normality of the response variable).
install.packages("nortest")
library(nortest)

m2$residuals
lillie.test(m2$residuals)
#P-value is well below 5% meaning that we reject the null. 
#In this case, it means that the residuals vary significantly from normality.
#It does not meet the normality assumption.

###Checking for constant variation
mean(m2$residuals)
par(mfrow=c(2,2))
plot(m2)
#The Residuals vs Fitted plot shows an increasing variation. This means that the assumption for 
#constant variation is not met. This also supports the conclusion that the residuals diverge from normal.
#The Q-Q plot matches the result of the lillie.test- not normal.
#The plot indicates outliers towards the end and beginning of the observations.

###Checking for independence of residuals
acf(m2$residuals)
#The acf function tells us that the residuals are mostly independent.However, there are 3 bars that slightly 
#cross the blue-dotted line. This indicates that there could be some correlation between a few of the residuals. 
#This is a similar finding to the independency of the covariates. They are moslty independent, but there are a few 
#that need to be checked for overlap.

### Checking for independence of covariates

##Numerical covariate independence check
install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)

nums <- data[, c("temperature", "bill", "pizzas")]

chart.Correlation(nums, method = "spearman", histogram = TRUE, pch = 16, main = "Correlation Matrix of Key Variables")
#This correlation chart tells us so much about the numerical covariates and their independence or lack there of.
#There is a slight negative correlation between temperature and bill, and also temperature and pizzas. Probably 
#for the same reason- more pizzas (higher price also) means a larger order -> longer prep time -> more time for pizza to lose heat.
#There is a pretty strong correlation between bill and pizzas. This makes sense because you spend more money on each pizza.
#This correlation might cause overemphasis of certain information.

##Categorical covariate independence check
branch.v.driver <- table(data$branch, data$driver)
chisq.test(branch.v.driver)                    
DescTools::CramerV(branch.v.driver) 

#Result:0.1498
#Interpretation: The correlation value indicates a weak positive correlation between the covariates branch and driver. 

branch.v.day <- table(data$branch, data$day)
chisq.test(branch.v.day)                    
DescTools::CramerV(branch.v.day) 

#Result:0.0680
#Interpretation: The correlation value indicates an independency between the covariates branch and day.

day.v.driver <- table(data$day, data$driver)
chisq.test(day.v.driver)                    
DescTools::CramerV(day.v.driver) 

#Result:0.3532
#Interpretation: The correlation value indicates a moderate level of correlation between the covariates day and driver.


#Based on these observations of independence or lack there of, we can conclude that there are some covariates that 
#we should consider merging or not including due to correlation. This could possibly help us reduce the danger of overemphasizing 
#certain information and making a more reliant model.

##Checking for continuous response variable
class(data$time)
#The outcome of this function is "numeric" which most likely indicates a continuous variable. 

#Overall, the assumptions of normality, independence of residuals, independence of covariates and constant variation
#are unmet, possibly met, unmet, and unmet respectively.

#### 8 ####
#Temperature, Domenico the driver, and the East branch cause the delivery time to be shortened (aka improved). 
#Whereas the bill and number of pizzas cause the order time to increase (aka delayed).

#### 9 ####
m_quad <- lm(time ~ temperature + I(temperature^2) + branch + day + driver + bill + pizzas, data = data)
m_quad

summary(m_quad)
#This summary shows an increase in the adjusted R-squared which immediately makes this a better model than our previous one. 
#This means that keeping the quadratic transformation of temperature in the model helps with its predictive power. 
#This quadratic transformation being helpful also allows us to say that the relationship between time and temperature is not strictly linear
#(because a curved shape provides a better fit)

anova(m2, m_quad)   # if p < 0.05, the quadratic term significantly improves fit
#This better fit is also supported in the results of the anova test: significantly low p-value that indicates the quad model is the superior choice.


#### 10 ####
last.captured.delivery <- data[nrow(data), ]   
View(last.captured.delivery)

predict(m1, newdata = latest_delivery)

#Result: 34.2296 minutes

#Points of comparison
#Actual time of last delivery: 35.7375

mean(data$time)
#Result: 36.5063 minutes

#Difference between actual and predicted: 1.5079
#Percent Error: 1.5079/35.7375 = 0.0422 aka 4.22%

#Interpretation: Using our latest model, we predict the time of the latest delivery to be 34.2296 minutes. 
#There is a percent error of 4.22 percent in this prediction. I am not sure of its significance based on context, but
#it would not come as a shock to me if this percent error was significant because of the 
#low value of the adjusted R-squared of our model.





