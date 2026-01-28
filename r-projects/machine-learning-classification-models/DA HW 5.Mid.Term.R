#### HW 5 ####
#### 1. OJ Data and Package Installation ####
library(tree)
library(ISLR)
data(OJ)
View(OJ)
?OJ
summary(OJ)
str(OJ)

#### 2. Producing Training and Test Sets ####
set.seed (1)
sample.index <- sample (1:nrow(OJ), 800)
train <- OJ[sample.index,]
test <- OJ[-sample.index, ]

#### 3 and 4. Produce a tree output/summary ####
tree.OJ <- tree(Purchase~., data = train)
tree.OJ
summary(tree.OJ)
##Training Data Rates:
##Misclass: 0.1588

#### 5. Plot the Tree ####
plot(tree.OJ)
text(tree.OJ ,pretty =0)

#### 6. Predict Response and Create Confusion Matrix ####
yhat <- predict (tree.OJ ,newdata = test, type = "class")
OJ.test <- test$Purchase   

conf.mat.tree <- table(yhat, OJ.test)
conf.mat.tree
mosaicplot(conf.mat.tree, shade = TRUE, main = "Confusion Matrix (Unpruned Tree)")
accuracy.tree <- mean(yhat == OJ.test)
accuracy.tree
misclassification.rate.tree <- 1 - accuracy.tree
misclassification.rate.tree
## Test Data Rates:
##Accuracy: 0.8296
##Misclass: 0.1704

#### 7, 8 and 9. Producing a Plot and Finding Optimal Tree Size ####
set.seed(2)
cv.OJ <- cv.tree(tree.OJ, FUN = prune.misclass, K = 10)
cv.OJ
plot(cv.OJ$size ,cv.OJ$dev ,type="b", main = "Cross-Validation to Find Optimal # of Nodes")

best.tree.index <- which.min(cv.OJ$dev)
best.tree.size <- cv.OJ$size[best.tree.index]
print(paste("The optimal tree size has", best.tree.size, "terminal nodes."))
##The optimal size is the same as the unpruned tree, so we will be using 5 terminal nodes instead.

#### 10. Pruned Tree Model ####
prune.OJ <- prune.tree(tree.OJ ,best = 5)
plot(prune.OJ)
text(prune.OJ ,pretty =0)
summary(prune.OJ)
##Training Data Rates:
##Misclass: 0.205


#### 11 ####
# The training misclassification error rate for the pruned tree is 4.62% higher than the one for the unpruned tree. 

#### 12 ####
# The test misclassification error rate for the pruned tree is 2.58% higher than the unpruned tree.

#### Predict Response and Create Confusion Matrix for the Pruned Tree
yhat.prune <- predict (prune.OJ ,newdata = test, type = "class")
OJ.test.prune <- test$Purchase   

conf.mat.prune <- table(yhat.prune, OJ.test.prune)
conf.mat.prune
mosaicplot(conf.mat.prune, shade = TRUE, main = "Confusion Matrix (Pruned Tree)")
accuracy.prune <- mean(yhat.prune == OJ.test.prune)
accuracy.prune
misclassification.rate.prune <- 1 - accuracy.prune
misclassification.rate.prune
## Test Data Rates:
##Accuracy: 0.8037
##Misclass: 0.1962

#### 13 ####
library (randomForest)
?randomForest()

p <- ncol(OJ) - 1 
##Bagging:
set.seed(4)
bag.OJ <- randomForest(Purchase~.,data = train, mtry = p, importance =TRUE)
bag.OJ
##Training Data Rates:
##Misclass: 20.75%

yhat.bag <- predict (bag.OJ ,newdata = test, type = "class")
OJ.test.bag <- test$Purchase  

conf.mat.bag <- table(yhat.bag, OJ.test.bag)
conf.mat.bag
accuracy.bag <- mean(yhat.bag == OJ.test.bag)
accuracy.bag
misclassification.rate.bag <- 1 - accuracy.bag
misclassification.rate.bag
## Test Data Rates:
##Accuracy: 0.8185
##Misclass: 0.1815


##Random Forest:
set.seed(5)
rf.OJ <- randomForest(Purchase~.,data = train, mtry = floor(sqrt(p)), importance =TRUE)
rf.OJ
##Training Data Rates:
##Misclass: 19.88%

yhat.rf <- predict (rf.OJ ,newdata = test, type = "class")
OJ.test.rf <- test$Purchase  

conf.mat.rf <- table(yhat.rf, OJ.test.rf)
conf.mat.rf
accuracy.rf <- mean(yhat.rf == OJ.test.rf)
accuracy.rf
misclassification.rate.rf <- 1 - accuracy.rf
misclassification.rate.rf
## Test Data Rates:
##Accuracy: 0.8259
##Misclass: 0.1741


##Boosting Method:
library (gbm)
train.bin.y <- ifelse(train$Purchase == "CH", 1, 0)
test.bin.y  <- ifelse(test$Purchase  == "CH", 1, 0)

class(test.bin.y)

set.seed (6)
boost.OJ <- gbm(train.bin.y~.-Purchase, data = transform(train, train.bin.y = train.bin.y),
            distribution = "bernoulli", interaction.depth = 4)
boost.OJ
summary(boost.OJ)

best.n.trees <- gbm.perf(boost.OJ, method = "OOB", plot.it = FALSE)
best.n.trees

phat.boost <- predict(boost.OJ, newdata = transform(test, test.bin.y = test.bin.y), n.trees = best.n.trees, type = "response")
yhat.boost <- factor(ifelse(phat.boost > 0.5, "CH", "MM"), levels = levels(test$Purchase))
OJ.test.boost <- test$Purchase

conf.mat.boost <- table(yhat.boost, OJ.test.boost)
conf.mat.boost
accuracy.boost <- mean(yhat.boost == OJ.test.boost)
accuracy.boost
misclassification.rate.boost <- 1 - accuracy.boost
misclassification.rate.boost
## Test Data Rates:
##Accuracy: 0.8296
##Misclass: 0.1704

#### SVM ####
install.packages("e1071")
library(e1071)
is.factor(train$Purchase)

##Linear SVM:
set.seed(1)
tune.lin.OJ <- tune(
  svm, Purchase ~ ., data = train,
  kernel = "linear",
  ranges = list(cost = c(0.001, 0.01, 0.1, 1, 5, 10, 100))
)
best.lin.OJ <- tune.lin.OJ$best.model
best.lin.OJ
summary(best.lin.OJ)

yhat.svm.lin <- predict(best.lin.OJ, newdata = test)
OJ.test.svm.lin <- test$Purchase  

conf.mat.svm.lin <- table(yhat.svm.lin, OJ.test.svm.lin)
conf.mat.svm.lin
accuracy.svm.lin <- mean(yhat.svm.lin == OJ.test.svm.lin)
accuracy.svm.lin
misclassification.rate.svm.lin <- 1 - accuracy.svm.lin
misclassification.rate.svm.lin

##Non-linear SVM
set.seed(1)
tune.rad.OJ <- tune(
  svm, Purchase ~ ., data = train,
  kernel = "radial",
  ranges = list(
    cost  = c(0.1, 1, 10, 100, 1000),
    gamma = c(0.5, 1, 2, 3, 4)
  )
)
best.rad.OJ <- tune.rad.OJ$best.model
best.rad.OJ
summary(best.rad.OJ)

yhat.svm.rad <- predict(best.rad.OJ, newdata = test)
OJ.test.svm.rad <- test$Purchase  

conf.mat.svm.rad <- table(yhat.svm.rad, OJ.test.svm.rad)
conf.mat.svm.rad
accuracy.svm.rad <- mean(yhat.svm.rad == OJ.test.svm.rad)
accuracy.svm.rad
misclassification.rate.svm.rad <- 1 - accuracy.svm.rad
misclassification.rate.svm.rad


#### Compare Models Code ####
#Tree Plots:
par(mfrow=c(1,2))
plot(tree.OJ)
text(tree.OJ ,pretty =0)
plot(prune.OJ)
text(prune.OJ ,pretty =0)
#Confusion Matrices:
par(mfrow=c(1,2))
mosaicplot(conf.mat.tree, shade = TRUE, main = "Confusion Matrix (Unpruned Tree)")
mosaicplot(conf.mat.prune, shade = TRUE, main = "Confusion Matrix (Pruned Tree)")

#Results Table:
res <- data.frame(
  Model = c("Unpruned", "Pruned", "Bagged", "Random Forest", "Boosted", "Linear SVM", "Non-linear SVM"),
  Accuracy = c(accuracy.tree,
               accuracy.prune,
               accuracy.bag,
               accuracy.rf,
               accuracy.boost,
               accuracy.svm.lin,
               accuracy.svm.rad)
)

res_desc <- res[order(res$Accuracy, decreasing = TRUE), ]
row.names(res_desc) <- NULL  # tidy row numbers
res_desc

#Code Check for Unpruned vs Boosted and Pruned vs Non-linear SVM:
identical(yhat, yhat.boost)#FALSE
sum(yhat != yhat.boost)#16 predictions are different

identical(yhat.prune, yhat.svm.rad)    #FALSE
sum(yhat.prune != yhat.svm.rad)   #50 predictions are different

#Because these pairs of models had the same accuracy, I wanted to make sure there wasn't an error in my coding. 






