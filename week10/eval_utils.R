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

plotRoc <- function(fpr_tpr, model_name) {
    ggplot(fpr_tpr, aes(x = TPR, y = FPR)) +
        geom_path() +
        geom_point(data = fpr_tpr[p %in% seq(0, 1, 0.2)]) +
        geom_text(
            data = fpr_tpr[p %in% seq(0, 1, 0.1)],
            aes(label = p), vjust = -0.5
        ) +
        scale_x_continuous(limits = c(0, 1)) +
        scale_y_continuous(limits = c(0, 1)) +
        labs(
            title = glue("ROC for {model_name} using all features"),
            subtitle = "Point labels represent probability cutoffs"
        ) +
        theme_minimal()
}
