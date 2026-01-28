#### HW 3 ####
#### Section One ####
library(MASS)

##Visualization and Understanding of Original Data:
?leuk
data("leuk")  
View(leuk)
names(leuk)
# Y: "time" (in weeks) X's: "wbc" (white blood count) "ag" (antigen presence or absence)

dim(leuk)
# 3x33

str(leuk)

summary(leuk)
#looking at "time", it is noticeable how big a difference there is between the median and 
#the mean. The median, 22, is a better representation of this data set of 33 people because
#the max observation skews the rest of the sample.

##Visualization of Response Variable "Time":
hist(leuk$time,xlab = "Survival Time (in weeks)", main = "Histogram Survival Time (in weeks)",xaxt = "n", yaxt = "n")
axis(1, at = seq(0, 160, by = 20))
axis(2, at = seq(0, 16, by = 4))

##Visualization of Response Variable "wbc":
hist(leuk$wbc,xlab = "White Blood Count (wbc)", main = "Histogram of White Blood Count (wbc)", yaxt = "n", breaks = 10)
axis(2, at = seq(0, 20, by = 4))

##Visualization of Response Variable "ag":
str(leuk$ag)
table(leuk$ag)
contrasts(leuk$ag)

barplot(table(leuk$ag),main = "Presence vs Absence of AG (Antigen)", xlab = "AG",ylab = "Frequency",)
#What I notice from this barplot is that it is pretty 50/50 on whether or not the antigens will be present or absent.

##Visualize "AG" and "Time" together:
library(ggplot2)

ggplot(leuk, aes(x =  ag, fill = time.binary.factor)) +
  geom_bar(position = "dodge") +
  labs(title = "Visualization of AG and Survival Time", x = "ag", y = "Frequency", fill = "Survival Time") 
#This group bar chart indicates a possible relationship with these two variables. It seems that 
#shorter survival times are more likely to occur when ag is absent.

##Visualize ""WBC" and "Time" together:
ggplot(leuk, aes(x = time.binary.factor, y = wbc, fill = time.binary.factor)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "wbc by Survival Outcome", x = "Survival Time", y = "wbc")
#This box-plot visual tells us a little bit about the relationship between survival time and wbc.
#It seems as though a lower wbc is more common in those who survived more than 24 weeks. Conversely, a higher wbc seems to be more likely in shorter survival times.
#This is noticed by looking at the medians (black bars) and noticing their positions in relation to the y-axis.

##After looking at the response variable and each covariate individually, I wonder if there will be a good logistic regression model
#to predict the response because there does seem to be a positive association between lower wbc and survival times as well as a 
#positive association between ag presence and survival time. So maybe, it doesn't matter how many white blood cells there are as long as 
#the antigen is present withing them. So, can we explain this relationship with a logistic regression model? Let's find out.


#### 1 ####
leuk$time.binary <- ifelse(leuk$time < 24, 0, 1) #creating a binary outcome
leuk$time.binary.factor <- factor(leuk$time.binary, levels = c(0, 1), labels = c("< 24 weeks", "≥ 24 weeks")) #putting it into factor form

##Data Checking:
str(leuk$time.binary.factor) #checking that it was properly converted into a factor
table(leuk$time.binary.factor)  #counts within factor levels
contrasts(leuk$time.binary.factor) #shows us the number assigned to each level...
#In our logistic regression, we will be calculating the probability that the response variable Y is in group 1.

#### 2 ####
leuk$wbc.log <- log(leuk$wbc)  #natural log transformation for wbc
str(leuk$wbc.log)

##Visualize the log transformation of wbc
hist(leuk$wbc.log,xlab = "White Blood Count (wbc)", main = "Histogram of Log Transformation of White Blood Count (wbc)")

model.1 <- glm(time.binary ~ wbc.log + ag, data = leuk, family = binomial)
model.1

summary(model.1)
exp(model.1$coefficients) #This indicates what odds a patient has of surviving at least 24 weeks given they have antigens present.
#Logistic Equation: logit = 3.4556 - 0.4822(log.wbc) + 1.7621 (leuk.agpresent)
#Interpretation: The presence of antigens have shown a significant impact on the response variable survival time.
#This is indicated by the p-value being less than a standard 5% alpha. People with the presence of antigens have a 5.8 times 
#higher chance of surviving at least 24 weeks. This is calculated by exponentiating the coefficient corresponding to AG. e^1.76 = 5.8. This logistic regression suggests that white 
#blood count does not have a significant impact on survival time. This is also shown by the p-value being much greater than 5%.
#To check whether or not this model is overfit, we divide the residual deviance by the degrees of freedom. In this case, we 
# get 1.25 which is below the threshhold of 1.5 which would indicate an overfit model. This is good. This means that our data, if significant, can be applied
#to other data sets and at least somewhat help in predicting the response variable outcome.



model.2 <- glm(leuk$time.binary ~ leuk$wbc + leuk$ag, family = binomial)
model.2
#Logistic Equation: logit = -8.706e-01 - 8.436e-06(wbc) + 1.733 (leuk.agpresent)
#This is a test of what the model would look like in if we did not take the natural log of wbc. The AIC is slightly higher than model 1, indicating that
#this model underperforms model 1 slightly. Model 1 is also slightly easier for interpretation purposes.


#### 3 ####
##Graphic for model interpretation: 
# 2) Build prediction grid
newdata <- with(leuk, expand.grid(
  wbc.log = seq(min(wbc.log), max(wbc.log), length.out = 200),
  ag      = levels(ag)
))

# 3) Predict from the model
newdata$predicted_prob <- predict(model.1, newdata = newdata, type = "response")

# Plot
library(ggplot2)
ggplot(newdata, aes(x = wbc.log, y = predicted_prob, color = ag)) +
  geom_line(size = 1.2) +
  labs(title = "Predicted Probability of Surviving ≥ 24 Weeks",
       x = "Log of White Blood Count (log WBC)",
       y = "Predicted Probability", color = "Antigen Presence") +
  theme_minimal(base_size = 13)



#### Section Two ####
library(ISLR)
##Visualization and Understanding of Original Data:
?Weekly
data("Weekly")  
View(Weekly)
names(Weekly)
# "Year"      "Lag1"      "Lag2"      "Lag3"      "Lag4"      "Lag5"      "Volume"    "Today"     "Direction"
dim(Weekly)
# 1089 x 9
str(Weekly)
#All are continuous except for direction, which is a factor.

summary(Weekly)

contrasts(Weekly$Direction) #Up is 1 which means the odds that we calculate will indicate the likelihood of the reponse being up in direction.

#### 1 ####
##Visualization of Original Data
par(mex=0.5)    #test for independent covariates
pairs(Weekly, gap=0, cex.labels=0.9)
cor(Weekly) 

library(PerformanceAnalytics)

chart.Correlation(Weekly[,-c(1,9)],method="spearman",histogram=TRUE,pch=16)

##Looking at both the normal correlation chart as well as the spearman correlation chart, there seems to be very little if any correlation between lags.
#There are some significant correlation values, however, they are so small that with such a large data set, it does not make a meaningful difference.
#Based on the first correlation chart, we can see an positive exponential relationship between time and volume, which makes sense. Since the developement of the 
#stock market, increasingly more people use it the net work affect occurs. As more people use it, it becomes a better market tool, meaning even more people
#want to participate. This is an easy explanation for that pattern.

#### 2 ####
model.3 <- glm(Direction ~ Lag1 + Lag2 + Lag3 + Lag4 + Lag5 + Volume, data = Weekly, family = binomial)
model.3

summary(model.3)
#Using the summary function in R, it can be seen that only one covariate is calculated to be significant.
#Based on its p-value less than 0.05, Lag 2 is significant in predicting the response variable direction. 
#No other covariate has a significant p-value. When dividing Residual deviance by degrees of freedom to check 
#the fit of the model, indicates it is close to being overfit. Greater than 1.5 means a model is overfit and this 
#model is 1.37. It also has a 1500 AIC score. This will become more meaningful in comparison to another model.

#### 3 ####
prob <- predict(model.3, type = "response")
predicted.classes <- ifelse(prob > 0.5, "Up", "Down")
conf.mat <- table(Predicted = predicted.classes, Actual = Weekly$Direction)
conf.mat

accuracy <- mean(predicted.classes == Weekly$Direction)
misclassification_rate <- 1 - accuracy
accuracy #=0.5611
misclassification_rate #=0.4389
##This misclassification stat tells us that 44 % of the time, this model will predict the wronf category for the response variable to go in.
#This is supported by the confusion matrix. 430 observations were misclassified as "Up" when in reality they were "Down". Another 48 observations 
#were categorized as "Down" when they were actually "Up". This indicates just how faulty this model is. It is not surprising since only one covariate was
#calculated to be significant.

#Now, what if we were to use only Lag 2 (the significant covariate) in a logistic regression model to predict Direction.
#Would that help in increasing the accuracy of the model? That is what we will see. In this next model, we will also use
#a training set and a test set so that we can more officially test if this model gives us the right predictions.

#### 4 ####
##Training data:
train <- (Weekly$Year < 2009)      
Weekly.train <- Weekly[train, ]    
Weekly.test <- Weekly[-train, ] 

model.4 <- glm(Direction ~ Lag2, data = Weekly.train, family = binomial)
model.4

summary(model.4)

##Predication using test data
glm.probs <- predict(model.4, newdata = Weekly.test, type = "response")
glm.pred <- rep("Down", nrow(Weekly.test))
glm.pred[glm.probs > 0.5] <- "Up"

# Confusion matrix
Direction.test <- Weekly.test$Direction
conf.mat.2 <- table(glm.pred, Direction.test)
conf.mat.2
accuracy.2 <- mean(glm.pred == Direction.test)
misclassification_rate.2 <- 1 - accuracy.2
accuracy.2 #=0.5625
misclassification_rate.2 #=0.4375
#Compared to the full model, this model that only takes into account Lag 2 has about the same amount of predictive power.
#This can be supported by a few things. The misclassification rate is a mere 0.0012 lower than with the full model. There were 476 misclassified observations out of 1088.
#The only other thing that points to this model being superior is the slight decrease in the AIC score from 1500 (full model) to 1354 (current model). 
#However, this model still does not do a good job of predicting the likelihood of the response variable ending up in the "Up" Direction category.

#### 5 ####
##LDA Model Fitting
model.4.lda <- lda(Direction ~ Lag2, data = Weekly.train)
model.4.lda

lda.pred <- predict(model.4.lda, Weekly.test)

Direction.test <- Weekly.test$Direction
conf.mat.3 <- table(lda.pred$class, Direction.test)
conf.mat.3
accuracy.lda <- mean(lda.pred$class == Direction.test)
misclassification_rate.lda <- 1 - accuracy.lda
accuracy.lda #=0.5616
misclassification_rate.lda #=0.4384

#### 6 ####
##QDA Model Fitting
model.4.qda <- qda(Direction ~ Lag2, data = Weekly.train)
model.4.qda

qda.pred <- predict(model.4.qda, Weekly.test)
Direction.test <- Weekly.test$Direction
conf.mat.4 <- table(qda.pred$class, Direction.test)
conf.mat.4
accuracy.qda <- mean(qda.pred$class == Direction.test)
misclassification_rate.qda <- 1 - accuracy.qda
accuracy.qda #= 0.5560
misclassification_rate.qda #0.4439
##This QDA model does not increase the accuracy. In fact, it decreases it by a small amount. This again points to Lag2 not having enough 
#significane for the test to differentiate the correct category for the response variable. Especially for this test. It predicted only 
#"Up" classifications. 


#### 7 ####
#All three of these models, Logistic, LDA, and QDA, come out with very similar predictions and misclassifications rates. All of them being approximately 56% accurate and 44% wrong. 
#This is barely better than flipping a coin to choose a category. There confusion matrices, though slightly different, hold pretty much the same amoun of miscalssified information. 
#The Logistic Regression Model is the best of the 3 though the difference is practically negligible. 
#Overall, I would say that this model model, nor any of the others in this report, can accurately predict the response variable direction. 