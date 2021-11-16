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
    fpr <- confusion_matrix[1, 2] / sum(confusion_matrix[1, ])
    tpr <- confusion_matrix[2, 2] / sum(confusion_matrix[2, ])
    data.table(FPR = fpr, TPR = tpr)
}

plotROC <- function(fpr_tpr, model_name) {
    ggplot(fpr_tpr, aes(x = FPR, y = TPR)) +
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

calculateROC <- function(actual, predictions) {
    purrr::map(seq(0, 1, 0.05), ~{
        calculateFPRTPR(getConfusionMatrix(
            actual = actual, predictions = predictions, cutoff = .x
        )) %>%
            .[, p := .x]
    }) %>%
        rbindlist()
}

calculateAUC <- function(actual, predictions) {
    suppressMessages({
        auc <- pROC::auc(response = actual, predictor = predictions) %>%
            attr("roc") %>%
            .[["auc"]] %>%
            as.numeric()

        return(auc)
    })
}
