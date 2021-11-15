calculateAccuracy <- function(actual, predictions, cutoff = 0.5) {
    N <- length(actual)
    accuracy <- sum(actual == as.integer(predictions > cutoff)) / N

    return(accuracy)
}

getConfusionMatrix <- function(actual, predictions, cutoff) {
    table(
        actual,
        factor(as.numeric(predictions > cutoff), levels = c(0, 1))
    )
}

calculateFPRTPR <- function(confusion_matrix) {
    fpr <- confusion_matrix[1, 1] / sum(confusion_matrix[1, ])
    tpr <- confusion_matrix[2, 1] / sum(confusion_matrix[2, ])
    data.table(FPR = fpr, TPR = tpr)
}
