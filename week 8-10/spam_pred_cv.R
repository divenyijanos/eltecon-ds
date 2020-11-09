library(data.table)
library(purrr)

data <- fread("spam_clean.csv")

# Define measure of interest
calculateAccuracy <- function(actual, predicted) {
    N <- length(actual)
    accuracy <- sum(actual == predicted) / N
    return(accuracy)
}

# cross-validation

folds <- 5
n <- nrow(data)

set.seed(2698)
holdout <- split(sample(1:n), 1:folds)

CV_ACC <- imap(holdout, ~{
    model <- glm(
        is_spam ~ nchar + nwords + nwords/nchar,
        data =  data[-.x,],
        family = binomial(link = "logit")
    )
    pred <- predict(model, newdata = data[.x,], type = "response")
    predicted_class <- ifelse(pred > 0.5, 1, 0)
    calculateAccuracy(data[.x,is_spam], predicted_class)
})

mean(unlist(CV_ACC))
