library(data.table)
library(purrr)

set.seed(1337)
n <- 50
x <- runif(n, min = 0, max = 1)
e <- rnorm(n, 0, 0.1)
y <- sin(2*pi*x) + e

data <- data.table(x = x, y = y)

folds <- 5

set.seed(2698)
holdout <- split(sample(1:n), 1:folds)

model_formula <- as.formula("y ~ x + I(x^2)")

MSE <- function(y, pred) {
    mean((y - pred)**2)
}

CV_MSE <- imap(holdout, ~{
    model <- lm(model_formula, data=data[-.x,])
    pred <- predict(model, newdata = data[.x,])
    MSE(data[.x,y],pred)
})


mean(unlist(CV_MSE))

library(caret)

train_control <- trainControl(method="cv", number=5)

set.seed(2698)
model <- train(model_formula, 
               data=data, 
               trControl=train_control, 
               method="lm")

model$resample
model$results$RMSE**2

# train_index <- createDataPartition(data$y, p=train_index, list=FALSE)
