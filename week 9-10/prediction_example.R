library(data.table)
library(ggplot2)
library(caret)
library(glmnet)

#Read in data
data <- fread('week 9-10/data/OnlineNewsPopularity_mod.csv')

# The target variable
summary(data$shares)
qplot(x = shares, data = data, geom = "histogram", bins = 100)
qplot(x = log(shares + 1), data = data, geom = "histogram", bins = 100)
data[, ln_shares:=log(shares)]

# Missing values

colSums(is.na(data))

# Separate holdout data
n <- nrow(data)
holdout_proportion <- 0.2
set.seed(23445)
holdout_index <- sample(1:n, floor(n*holdout_proportion))

data_holdout <- data[holdout_index,]
data <- data[-holdout_index,]


# Define variable groups
var.names <- names(data)
x.words <- var.names[c(2:6,11)]
x.links <- var.names[c(7:8,28:30)]
x.dig <- var.names[9:10]
x.key <- var.names[c(12,19:27)]
x.channel <- var.names[13:18]
x.NLP <- var.names[31:51]


# Define candidate models
X0 <- "constant"
X1 <- paste0(x.channel, collapse = " + ")
X2 <- paste0(c(x.channel, x.key), collapse = " + ")
X3 <- paste0(c(x.channel, x.key, x.dig), collapse = " + ")
X4 <- paste0(c(x.channel, x.key, x.dig, x.links), collapse = " + ")
X5 <- paste0(c(x.channel, x.key, x.dig, x.links, x.words, x.NLP), collapse = " + ")
X6 <- paste0(paste0(c(x.key, x.links, x.words, x.NLP), collapse = " + "), " + ", 
             paste0("(",paste0(x.dig, collapse = " + "),")*(",
                    paste0(x.channel, collapse = " + "),")"))

models <- c("X0", "X1", "X2", "X3", "X4", "X5", "X6")

# Define measure of fit
MSE <- function(y, pred) {
    mean((y - pred)**2)
}

# Train and test data
n <- nrow(data)
train_proportion <- 0.7
set.seed(23445)
train_index <- sample(1:n, floor(n*train_proportion))

data_train <- data[train_index,]
data_test <- data[-train_index,]


mse_train <- list()
mse_test <- list()
for (model in models) {
   
    model_formula <- as.formula(paste0("ln_shares ~", get(model)))     
    model_fit <- lm(model_formula, data = data_train)

    colname <- paste0("pred",model)
    data_train <- data_train[, eval(colname):=predict(model_fit, newdata = data_train)]
    mse_train[[colname]] <-  MSE(data_train[, ln_shares], data_train[, get(colname)])
    data_test <- data_test[, eval(colname):=predict(model_fit, newdata = data_test)]
    mse_test[[colname]] <-  MSE(data_test[, ln_shares], data_test[, get(colname)])
}

cbind("train MSE" = unlist(mse_train), "test MSE" = unlist(mse_test))

# Cross-validation
mse_cross <- list()

train_control <- trainControl(method="cv", number=5)
for (model in models) {
    model_formula <- as.formula(paste0("ln_shares ~", get(model)))     
    model_fit <- train(model_formula, 
                   data=data, 
                   trControl=train_control, 
                   method="lm")
    mse_cross[[model]] <-  model_fit$results$RMSE**2
}

cbind("train MSE" = unlist(mse_train), "test MSE" = unlist(mse_test), "CV MSE" = unlist(mse_cross))

# Regularisation
model_formula <- as.formula(paste0("ln_shares ~", get("X6")))
X <- model.matrix(model_formula, data = data_train)[,-1]
X_test <- model.matrix(model_formula, data = data_test)[,-1]

ridge_best <- cv.glmnet(X, data_train$ln_shares, alpha = 0)
bestlam <- ridge_best$lambda.min
coef(ridge_best)

data_train <- data_train[, "ridge_best":=predict(ridge_best, s = bestlam, newx =  X)]
data_test <- data_test[, "ridge_best":=predict(ridge_best, s = bestlam, newx =  X_test)]

lasso_best <- cv.glmnet(X, data_train$ln_shares, alpha = 1)
bestlam <- lasso_best$lambda.min
coef(lasso_best)
plot(lasso_best)

data_train <- data_train[, "lasso_best":=predict(lasso_best, s = bestlam, newx =  X)]
data_test <- data_test[, "lasso_best":=predict(lasso_best, s = bestlam, newx =  X_test)]

for (model in c("ridge_best", "lasso_best")) {
    mse_train[[model]] <-  MSE(data_train[, ln_shares], data_train[, get(model)])
    mse_test[[model]] <-  MSE(data_test[, ln_shares], data_test[, get(model)])
    mse_cross[[model]] <-  min(get(model)$cvm)
}


cbind("train MSE" = unlist(mse_train), "test MSE" = unlist(mse_test), "CV MSE" = unlist(mse_cross))

# Performance on holdout set
model_formula <- as.formula(paste0("ln_shares ~", get("X4")))
model_fit <- lm(model_formula, data = data_train)

data_holdout <- data_holdout[, pred:=predict(model_fit, newdata = data_holdout)]
MSE(data_holdout[, ln_shares], data_holdout[, pred])
