library(data.table)
library(ggplot2)
library(magrittr)
library(rpart)
library(purrr)

# Data
set.seed(20211020)
spam <- fread("week4/data/spam_clean.csv")

train_proportion <- 0.8
n <- nrow(spam)
set.seed(20211020)
train_index <- sample(1:n, floor(n * train_proportion))

data_to_use <- spam[, -c(2, 50:400)]  # exclude columns to speed up
data_train <- data_to_use[train_index,]
data_test <- data_to_use[-train_index,]

# Estimate models (logistic regression + tree)
logit_model <- glm(is_spam ~ ., family = binomial(link = "logit"), data = data_train)
tree_model <- rpart(is_spam ~ ., data = data_train)

# Calculate FPR, TPR, accuracy for a given probability cutoff
logit_predictions <- predict(logit_model, newdata = data_test, type = "response")
tree_predictions <- predict(tree_model, newdata = data_test)

getConfusionMatrix <- function(predictions, cutoff) {
    table(
        data_test$is_spam,
        factor(as.numeric(predictions > cutoff), levels = c(0, 1))
    )
}

calculatePerfomanceMeasures <- function(confusionMatrix) {
    data.table(
        TPR = confusionMatrix[2, 2] / sum(confusionMatrix[2, ]),
        FPR = confusionMatrix[1, 2] / sum(confusionMatrix[1, ]),
        accuracy = (confusionMatrix[1, 1] + confusionMatrix[2, 2]) / sum(confusionMatrix)
    )
}


# Run the calculation for a lot of different prob cutoffs
logit_results <- map_df(seq(0, 1, 0.05), ~{
    calculatePerfomanceMeasures(getConfusionMatrix(logit_predictions, .x)) %>%
        .[, cutoff := .x]
})

tree_results <- map_df(seq(0, 1, 0.05), ~{
    calculatePerfomanceMeasures(getConfusionMatrix(tree_predictions, .x)) %>%
        .[, cutoff := .x]
})

# Plot the results
ggplot(logit_results, aes(FPR, TPR)) +
    geom_path() +
    coord_fixed() +
    geom_point(data = logit_results[accuracy == max(accuracy)]) +
    geom_path(data = tree_results, color = "firebrick") +
    geom_point(data = tree_results[accuracy == max(accuracy)], color = "firebrick") +
    annotate("text", 0.75, 0.5, label = "logit") +
    annotate("text", 0.75, 0.4, label = "tree", color = "firebrick")
