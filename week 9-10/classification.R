library(data.table)
library(ggplot2)
library(purrr)
library(rpart)
library(rpart.plot)
library(randomForest)


# EDA -------------------------------------------------------------------------

returning_buyers <- fread("data/returning_buyers.csv")
returning_buyers[, returning_buyer := as.factor(returning_buyer)]

# Quick explore
ggplot(returning_buyers, aes(returning_buyer)) + geom_bar()
GGally::ggpairs(returning_buyers)

# Data splitting
train_proportion <- 0.8
n <- nrow(returning_buyers)
set.seed(20191127)
train_index <- sample(1:n, floor(n * train_proportion))

data_train <- returning_buyers[train_index,]
data_test <- returning_buyers[-train_index,]

# Logistic regression ---------------------------------------------------------
glm_model <- glm(returning_buyer ~ ., data = data_train, family = "binomial")
glm_model

calculatePredictedOutcome <- function(predictions, cutoff) {
    factor(as.numeric(predictions > cutoff), levels = c(0, 1))
}

confusionMatrix <- function(predictions, data, cutoff = 0.5) {
    predicted_outcome <- calculatePredictedOutcome(predictions, cutoff)
    table(predicted_outcome, data$returning_buyer)
}

calculateAccuracy <- function(predictions, data, cutoff = 0.5) {
    predicted_outcome <- calculatePredictedOutcome(predictions, cutoff)
    mean(predicted_outcome == data$returning_buyer)
}

walk(list(data_train, data_test), ~{
    predictions <- predict(glm_model, .x, type = "response")
    print(confusionMatrix(predictions, .x))
    print(paste("Accuracy:", calculateAccuracy(predictions, .x)))
})



# ROC curve -------------------------------------------------------------------

calculateFPRTPR <- function(confusion_matrix) {
    fpr <- confusion_matrix[2, 1] / sum(confusion_matrix[, 1])
    tpr <- confusion_matrix[2, 2] / sum(confusion_matrix[, 2])
    data.table(FPR = fpr, TPR = tpr)
}

calculateFPRTPR(confusionMatrix(predict(glm_model, data_train, type = "response"), data_train))
calculateFPRTPR(confusionMatrix(predict(glm_model, data_test, type = "response"), data_test))

predicted_probs_glm <- predict(glm_model, data_test, type = "response")

generateROCdata <- function(predictions) {
    map_df(seq(0, 1, 0.01), ~{
        confusionMatrix(predictions, data_test, cutoff = .x) %>%
        calculateFPRTPR()
    })
}

roc_data_glm <- generateROCdata(predicted_probs_glm)

roc_plot <- ggplot(roc_data_glm, aes(FPR, TPR)) +
    geom_path() +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(limits = c(0, 1)) +
    coord_fixed()
roc_plot

# Tree model ------------------------------------------------------------------
tree_model <- rpart(
    returning_buyer ~ ., data = data_train,
    control = rpart.control(minsplit = 2, minbucket = 1, cp = 0)
)
tree_model

getTreePredictions <- function(tree_model, data) {
    predict(tree_model, data, type = "prob") %>% .[, 2]
}

calculateAccuracy(getTreePredictions(tree_model, data_train), data_train)
calculateAccuracy(getTreePredictions(tree_model, data_test), data_test)

prune(tree_model, cp = 1) %>% rpart.plot()
prune(tree_model, cp = 0.1) %>% rpart.plot()
prune(tree_model, cp = 0.01) %>% rpart.plot()

accuracy_by_params <- map_df(seq(0, 0.5, 0.001), ~{
    pruned_tree <- prune(tree_model, cp = .x)
    data.table(
        cp = .x,
        train_accuracy = calculateAccuracy(getTreePredictions(pruned_tree, data_train), data_train),
        test_accuracy = calculateAccuracy(getTreePredictions(pruned_tree, data_test), data_test)
    )
})

ggplot(melt(accuracy_by_params, id.vars = "cp"), aes(cp, value, color = variable)) + geom_line()

# with default settings
default_tree_model <- rpart(returning_buyer ~ ., data = data_train)
rpart.plot(default_tree_model)
calculateAccuracy(getTreePredictions(default_tree_model, data_test), data_test)

# ROC -------------------------------------------------------------------------

# simple tree
predicted_probs_simple_tree <- getTreePredictions(prune(tree_model, 0.1), data_test)
confusionMatrix(predicted_probs_simple_tree, data_test, 0.5) %>% calculateFPRTPR()

roc_data_simple_tree <- generateROCdata(predicted_probs_simple_tree)
roc_plot <- roc_plot + geom_path(data = roc_data_simple_tree, color = "red")
roc_plot

# complex tree
predicted_probs_complex_tree <- getTreePredictions(prune(tree_model, 0.01), data_test)

roc_data_complex_tree <- generateROCdata(predicted_probs_complex_tree)
roc_plot <- roc_plot + geom_path(data = roc_data_complex_tree, color = "orange")
roc_plot

# default tree
predicted_probs_default_tree <- getTreePredictions(default_tree_model, data_test)

roc_data_default_tree <- generateROCdata(predicted_probs_default_tree)
roc_plot <- roc_plot + geom_path(data = roc_data_default_tree, color = "darkred")
roc_plot

# Ensemble --------------------------------------------------------------------

# Bagged trees
bagged_tree_model <- randomForest(returning_buyer ~ ., data = data_train, mtry = 6)
bagged_tree_model

predicted_probs_bagging <- predict(bagged_tree_model, data_test, type = "prob") %>% .[, 2]
calculateAccuracy(predicted_probs_bagging, data_test)
confusionMatrix(predicted_probs_bagging, data_test, 0.5) %>% calculateFPRTPR()

roc_data_bagging <- generateROCdata(predicted_probs_bagging)
roc_plot <- roc_plot + geom_path(data = roc_data_bagging, color = "navy")
roc_plot


# Random forest
random_forest_model <- randomForest(returning_buyer ~ ., data = data_train)
random_forest_model

predicted_probs_rf <- predict(random_forest_model, data_test, type = "prob") %>% .[, 2]
calculateAccuracy(predicted_probs_rf, data_test)
confusionMatrix(predicted_probs_rf, data_test, 0.5) %>% calculateFPRTPR()

roc_data_rf <- generateROCdata(predicted_probs_rf)
roc_plot <- roc_plot + geom_path(data = roc_data_rf, color = "darkgreen")
roc_plot


# Recommended resources -------------------------------------------------------

# ISLR Ch8
# www.r2d3.us
# Machine Learning meets economics: https://blog.mldb.ai/blog/posts/2016/01/ml-meets-economics/
# FPR, TPR: https://www.youtube.com/watch?v=sunUKFXMHGk (StatQuest)
# ROC curve: https://www.youtube.com/watch?v=4jRBRDbJemM (StatQuest)
