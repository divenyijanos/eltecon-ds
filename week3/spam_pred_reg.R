library(data.table)
library(glmnet)
library(purrr)

data <- fread("week 8-10/data/spam_clean.csv")

# Define measure of interest
calculateAccuracy <- function(actual, predicted) {
    N <- length(actual)
    accuracy <- sum(actual == predicted) / N
    return(accuracy)
}

# Seperate train-test set
train_proportion <- 0.8
n <- nrow(data)
set.seed(1234)
train_index <- sample(1:n, floor(n*train_proportion))

data_train <- data[train_index,-2]
data_test <- data[-train_index,-2]

# Data preparation
model_formula <- as.formula(is_spam ~ .)
X <- model.matrix(model_formula, data = data_train)[,-1]
y <- factor(data_train$is_spam)
X_test <- model.matrix(model_formula, data =  data_test)[,-1]

# logistic regression
logistic <- glm(model_formula, data = data_train, family = binomial(link = "logit"))

data_test <- data_test %>% 
    .[, predicted_prob_logistic := predict.glm(logistic, newdata = data_test, type = "response")] %>% 
    .[, predicted_class_logistic := ifelse(predicted_prob_logistic > 0.5, 1, 0)]

calculateAccuracy(data_test$is_spam, data_test$predicted_class_logistic)

#Ridge
ridge <- glmnet(X, y, family = "binomial", alpha = 0, type.measure="class", lambda = 0.2)

data_test <- data_test %>% 
    .[, predicted_prob_ridge := predict(ridge, newx = X_test)] %>% 
    .[, predicted_class_ridge := ifelse(predicted_prob_ridge > 0.5, 1, 0)]

calculateAccuracy(data_test$is_spam, data_test$predicted_class_ridge)

# Cross-validated ridge
set.seed(2698)
ridge_cv <- cv.glmnet(X, y, family = "binomial", alpha = 0, type.measure="class", nfolds=5)
bestlam_ridge <- ridge_cv$lambda.min
coef(ridge_cv)

data_test <- data_test %>% 
    .[, predicted_prob_ridge_best := predict(ridge_cv, newx = X_test, s = bestlam_ridge)] %>% 
    .[, predicted_class_ridge_best := ifelse(predicted_prob_ridge_best > 0.5, 1, 0)]

calculateAccuracy(data_test$is_spam, data_test$predicted_class_ridge_best)

