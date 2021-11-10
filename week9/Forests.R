library(data.table)
library(ggplot2)
library(rpart)
library(randomForest)

# Data
set.seed(20211020)
spam <- fread("week4/data/spam_clean.csv")

train_proportion <- 0.8
n <- nrow(spam)
set.seed(20211020)
train_index <- sample(1:n, floor(n * train_proportion))

data_to_use <- spam[, -c(2, 50:400)]  # exclude columns to speed up
data_to_use$is_spam <- as.factor(data_to_use$is_spam) 
data_train <- data_to_use[train_index,]
data_test <- data_to_use[-train_index,]

# Estimate models (logistic regression)
logit_model <- glm(is_spam ~ ., family = binomial(link = "logit"), data = data_train)
logit_predictions <- predict(logit_model, newdata = data_test, type = "response")

## Exercise 1: predict spams using a classification tree
tree_model <- rpart(is_spam ~ ., data = data_train)
tree_predictions <- predict(tree_model, newdata = data_test)

## Exercise 2: predict spams using bagging
#bagging_model <- randomForest(is_spam~., data = data_train, mtry=51,importance =TRUE, ntree=100)
bagging_model <- randomForest(, data = , mtry=, importance =, ntree = )
#bagging_predictions <- predict(bagging_model, newdata = data_test)

print(bagging_model)

importance(bagging_model)
varImpPlot(bagging_model)

## Exercise 3: predict spams using random forests
#rf_model <- randomForest(is_spam~., data = data_train, mtry=sqrt(51),importance =TRUE, ntree=100)
rf_model <- randomForest(, data = , mtry=, importance =, ntree = )
rf_predictions <- predict(rf_model, newdata = data_test)

print(rf_model)


