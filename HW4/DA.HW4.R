#### HW 4 ####
#### 1 ####
library(ISLR)
data(OJ)
View(OJ)
?OJ
summary(OJ)
str(OJ)

### Visuals of Data
library(ggplot2)

ggplot(OJ, aes(x = Purchase, fill = Purchase)) +
  geom_bar() +
  labs(title = "Distribution of Purchase Types")

### Numerical Data
num_vars <- OJ[, sapply(OJ, is.numeric)]

library(PerformanceAnalytics)
chart.Correlation(num_vars,method="spearman",histogram=TRUE,pch=16, main = "Correlation Chart")

#### a ####
set.seed (1)
sample.index = sample (1:nrow(OJ), 800)
train <- OJ[sample.index,]
test <- OJ[-sample.index, ]

#### b ####
### Ridge Regression
library (glmnet )

#Split Data intor Train and Test Data
x_train <- model.matrix(Purchase ~ ., data = train)[, -1]
y_train <- train$Purchase

x_test  <- model.matrix(Purchase ~ ., data = test)[, -1]
y_test  <- test$Purchase

contrasts(OJ$Purchase)

#Determine Best Lambda Using Cross-Validation
cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0, family = "binomial")
plot(cv_ridge, main = "Cross-Validation Curve for Ridge Regression")

#Best Lambda
cv_ridge$lambda.min
# =0.031

#Ridge Regression Given Best Lambda
ridge_mod <- glmnet(x_train, y_train, alpha = 0, family = "binomial", lambda = cv_ridge$lambda.min)
ridge_mod
summary(ridge_mod)

ridge_probs <- predict(ridge_mod, s = cv_ridge$lambda.min, newx = x_test, type = "response")
ridge_probs
ridge_pred <- ifelse(ridge_probs > 0.5, "MM", "CH")
ridge_pred <- factor(ridge_pred, levels = levels(y_test))

conf.mat.ridge <- table(ridge_pred, y_test)
accuracy.ridge <- mean(ridge_pred == y_test)
misclassification.rate.ridge <- 1 - accuracy.ridge

print(conf.mat.ridge)
print(accuracy.ridge)
print(misclassification.rate.ridge)

#### c ####
coef(ridge_mod)

#### d ####
y_test_num <- ifelse(y_test == "MM", 1, 0) 
#turning the factors into binary outcomes so that it can 
#the predicted probabilities can be subtracted and a mean residual error can be found.
ridge_mse <- mean((y_test_num - ridge_probs)^2)
ridge_mse
#=0.132

#### e ####
### Lasso Regression
#Determine Best Lambda Using Cross-Validation
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1, family = "binomial")
plot(cv_lasso, main = "Cross-Validation Curve for Lasso Regression")

#Best Lambda
cv_lasso$lambda.min
#=0.009

#Ridge Regression Given Best Lambda
lasso_mod <- glmnet(x_train, y_train, alpha = 1, family = "binomial", lambda = cv_lasso$lambda.min)
lasso_mod

coef(lasso_mod)

lasso_probs <- predict(lasso_mod, s = cv_lasso$lambda.min, newx = x_test, type = "response")
lasso_probs
lasso_pred <- ifelse(lasso_probs > 0.5, "MM", "CH")
lasso_pred <- factor(lasso_pred, levels = levels(y_test))

conf.mat.lasso <- table(lasso_pred, y_test)
accuracy.lasso <- mean(lasso_pred == y_test)
misclassification.rate.lasso <- 1 - accuracy.lasso

print(conf.mat.lasso)
print(accuracy.lasso)
print(misclassification.rate.lasso)

lasso_mse <- mean((y_test_num - lasso_probs)^2)
lasso_mse
#=0.126

#### f ####
cv_lasso$lambda.min
#=0.009

#### g ####
accuracy.diff.pct <- (accuracy.lasso - accuracy.ridge)*100
accuracy.diff.pct
#0.74% This means the lasso model makes correct predictions 0.74% more times than the ridge model.
#Is it a huge difference? No, but in a much larger population, this percentage could make a significant impact.
#Therefore, the lasso is the superior test according to the accuracy estimate alone.

#The lasso also has a slightly lower MSE (smaller by 0.006). This also indicates a superior model.

#### h ####
#Overall, which of these models is best? The lasso regression model achieves greater accuracy with a smaller MSE while also 
#keeping a smaller number of covariates. This indicates a simpler model with greater ease of interpretability. 




#### 2 ####
data(USArrests)
View(USArrests)
?USArrests
summary(USArrests)
str(USArrests)
head(USArrests)

library (pls)
?pcr
?prcomp

#Splitting Data into Principle Components
pca.fit <- prcomp(USArrests, scale. = TRUE)
pca.fit
summary(pca.fit)

#Visual for PCA
biplot(pca.fit, scale=0, main = "Principle Component Analysis Visual")



