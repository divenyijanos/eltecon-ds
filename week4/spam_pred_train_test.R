library(data.table)
library(purrr)

data <- fread("spam_clean.csv")

# Seperate train-test set
train_proportion <- 0.7
n <- nrow(data)
set.seed(1234)
train_index <- sample(1:n, floor(n*train_proportion))

data_train <- data[train_index,]
data_test <- data[-train_index,]

# Define measure of interest
calculateAccuracy <- function(actual, predicted) {
  N <- length(actual)
  accuracy <- sum(actual == predicted) / N
  return(accuracy)
}

# baseline prediction
table(data_train$is_spam)
1-sum(data_test$is_spam)/length(data_test$is_spam)

# model 1
model1 <- glm(
  is_spam ~ nchar + nwords + nwords/nchar,
  data = data_train,
  family = binomial(link = "logit")
)

predicted_prob1_train <- predict.glm(model1, newdata = data_train, type = "response")
predicted_class1_train <- ifelse(predicted_prob1_train > 0.5, 1, 0)
model1_train_acc <- calculateAccuracy(data_train$is_spam, predicted_class1_train)
model1_train_acc

predicted_prob1 <- predict.glm(model1, newdata = data_test, type = "response")
predicted_class1 <- ifelse(predicted_prob1 > 0.5, 1, 0)
model1_test_acc <- calculateAccuracy(data_test$is_spam, predicted_class1)
model1_test_acc

table(data_test$is_spam, predicted_class1, dnn = c("actual", "predicted"))

# model 2
model2 <- glm(
  is_spam ~ .,
  data = data_train[,c(1, 3:54)],
  family = binomial(link = "logit")
)

predicted_prob2_train <- predict.glm(model2, newdata = data_train, type = "response")
predicted_class2_train <- ifelse(predicted_prob2_train > 0.5, 1, 0)
model2_train_acc <- calculateAccuracy(data_train$is_spam, predicted_class2_train)
model2_train_acc

predicted_prob2 <- predict.glm(model2, newdata = data_test, type = "response")
predicted_class2 <- ifelse(predicted_prob2 > 0.5, 1, 0)
model2_test_acc <- calculateAccuracy(data_test$is_spam, predicted_class2)
model2_test_acc

table(data_test$is_spam, predicted_class2, dnn = c("actual", "predicted"))

list(model1 = c(train = round(model1_train_acc, 2), test = round(model1_test_acc, 2)),
     model2 = c(train = round(model2_train_acc, 2), test = round(model2_test_acc, 2)))

# is_sign <- summary(model2)$coeff[-1,4] < 0.01
# summary(model2)$coeff[is_sign,]
