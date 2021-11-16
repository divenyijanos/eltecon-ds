library(knitr)
library(data.table)
library(ggplot2)
library(magrittr)
library(tidytext)
library(glue)
library(here)
library(patchwork)
library(rpart)
library(pROC)
library(ranger)

source(here::here("week10", "eval_utils.R"))

## Exploratory analysis

sms <- fread(
    here::here("week10", "data", "spam.csv"),
    header = TRUE,
    select = c("v1", "v2"),
    col.names = c("is_spam", "sms_text"),
    encoding = 'Latin-1'
) %>%
    .[, is_spam := ifelse(is_spam == "spam", 1, 0)]


sms %>%
    .[, .N, by = "is_spam"] %>%
    .[, share := scales::percent(N / sum(N), accuracy = 0.01)] %>%
    .[]

### Message length

sms[, sms_chr_length := nchar(sms_text)]

sms[, .(avg_sms_chr_length = mean(sms_chr_length)), by = "is_spam"]


spam_chr_length     <- sms[is_spam == 1, .(median_sms_chr_length = median(sms_chr_length))]
non_spam_chr_length <- sms[is_spam == 0, .(median_sms_chr_length = median(sms_chr_length))]

ggplot(
    sms,
    aes(x = sms_chr_length, fill = as.factor(is_spam), color = as.factor(is_spam))
) +
    geom_density(alpha = 0.5) +
    labs(
        title = "Densities number of characters by sms type",
        subtitle = glue(
            "Median sms char. lengths: spam = {spam_chr_length}",
            ", non-spam: {non_spam_chr_length}"
        )
    ) +
    theme_minimal() +
    theme(legend.position = "top")


### Tokenization


sms[, message_id := 1:.N]

sms_words <- sms %>%
    .[, .(message_id, sms_text)] %>%
    tidytext::unnest_tokens(output = "word", input = "sms_text") %>%
    data.table()

# EXERCISE: flag stopwords:
# TODO add solution

sms_words %>%
    .[, is_stopword := ifelse(nchar(word) == 1, TRUE, is_stopword)] %>%
    .[, is_stopword := ifelse(grepl("^\\d+$", word), TRUE, is_stopword)]

#### Number of words

sms_word_lengths <- merge(
    sms_words[, .(num_words = .N), by = "message_id"],
    sms_words[is_stopword == FALSE, .(num_non_stopwords = .N), by = "message_id"],
    by = "message_id",
    all.x = TRUE
) %>%
    .[, num_non_stopwords := dplyr::coalesce(num_non_stopwords, 0)]

sms <- merge(
    sms, sms_word_lengths, by = "message_id"
)

## EXERCISE: plot the distribution of `num_words` by `is_spam`!
# TODO add solution

## Most frequent words

sms_words <- merge(
    sms_words, sms[, .(message_id, is_spam)], by = "message_id"
)

num_spam_msgs <- sms_words[is_spam == 1, uniqueN(message_id)]
word_occurrences_in_spam <- sms_words[
    is_spam == 1,
    .(
        num_occurence_in_spam = uniqueN(message_id),
        prevalence_in_spam = uniqueN(message_id) / num_spam_msgs
    ),
    by = c("word", "is_stopword")
]

num_non_spam_msgs <- sms_words[is_spam == 0, uniqueN(message_id)]
word_occurrences_in_non_spam <- sms_words[
    is_spam == 0,
    .(
        num_occurence_in_non_spam = uniqueN(message_id),
        prevalence_in_non_spam = uniqueN(message_id) / num_non_spam_msgs
    ),
    by = c("word", "is_stopword")
]

word_occurrences <- merge(
    word_occurrences_in_spam, word_occurrences_in_non_spam,
    by = c("word", "is_stopword"), all = TRUE
) %>%
    .[, `:=`(
        prevalence_in_spam = dplyr::coalesce(prevalence_in_spam, 0),
        prevalence_in_non_spam = dplyr::coalesce(prevalence_in_non_spam, 0),
        num_occurence_in_spam = dplyr::coalesce(num_occurence_in_spam, 0),
        num_occurence_in_non_spam = dplyr::coalesce(num_occurence_in_non_spam, 0)
    )] %>%
    .[, num_occurance := num_occurence_in_spam + num_occurence_in_non_spam]

p1 <- word_occurrences[order(-num_occurance)][1:20] %>%
    ggplot(aes(x = reorder(word, num_occurance))) +
        geom_col(aes(y = prevalence_in_spam), fill = "red") +
        labs(x = "avg_prevalence", title = "Spam") +
        ylim(c(0, 0.65)) +
        coord_flip() +
        theme_minimal() +
        theme(legend.position = "top")

p2 <- word_occurrences[order(-num_occurance)][1:20] %>%
    ggplot(aes(x = reorder(word, num_occurance))) +
        geom_col(aes(y = prevalence_in_non_spam), fill = "blue") +
        labs(x = "avg_prevalence", title = "Non-spam") +
        ylim(c(0, 0.65)) +
        coord_flip() +
        theme_minimal() +
        theme(legend.position = "top")

patchwork::wrap_plots(p1, p2) +
    patchwork::plot_annotation(
          title = "Prevalence of top 20 words by frequency in messages",
          subtitle = "Includes stopwords",
    )

p1 <- word_occurrences[is_stopword == FALSE][order(-num_occurance)][1:20] %>%
    ggplot(aes(x = reorder(word, num_occurance))) +
        geom_col(aes(y = prevalence_in_spam), fill = "red") +
        labs(x = "avg_prevalence", title = "Spam") +
        ylim(c(0, 0.65)) +
        coord_flip() +
        theme_minimal() +
        theme(legend.position = "top")

p2 <- word_occurrences[is_stopword == FALSE][order(-num_occurance)][1:20] %>%
    ggplot(aes(x = reorder(word, num_occurance))) +
        geom_col(aes(y = prevalence_in_non_spam), fill = "blue") +
        labs(x = "avg_prevalence", title = "Non-spam") +
        ylim(c(0, 0.65)) +
        coord_flip() +
        theme_minimal() +
        theme(legend.position = "top")

patchwork::wrap_plots(p1, p2) +
    patchwork::plot_annotation(
          title = "Prevalence of top 20 words by frequency in messages",
          subtitle = "Excludes stopwords",
    )


### Words with biggest descrepancy in their frequency

top20_diff_words <- word_occurrences %>%
    .[is_stopword == FALSE] %>%
    .[num_occurance >= 5] %>%
    .[, prevalence_diff := abs(prevalence_in_spam - prevalence_in_non_spam)] %>%
    .[order(-prevalence_diff)] %>%
    .[1:20] %>%
    .[, word]


all_msg_ids_w_top20_diff_words <- CJ(
    sms[, unique(message_id)], top20_diff_words
) %>%
    setnames(c("message_id", "word"))


top20_diff_words_one_hot <- merge(
    all_msg_ids_w_top20_diff_words,
    sms_words[, .(message_id, word, contains_word = 1)],
    by = c("message_id", "word"),
    all.x = TRUE
) %>%
    .[, contains_word := dplyr::coalesce(contains_word, 0)] %>%
    dcast(message_id ~ word, value.var = 'contains_word', fun.aggregate = max)

top20_diff_words_one_hot

sms <- merge(sms, top20_diff_words_one_hot, by = "message_id")

## Predictive modeling


### Train / test split

## Exercise: create an 80% train/test split!
# TODO add solution

### Baseline model

baseline_model <- rpart(
    is_spam ~ sms_chr_length,
    data = train,
    control = rpart.control(maxdepth = 1)
)
baseline_model

### Evaluation of baseline model

baseline_predictions <- predict(baseline_model, newdata = test)

Predictions will only take on two values (due to the single-split control), so we can take their avg. as our cutoff to assign classes to predicted probabilities:
baseline_cutoff <- mean(unique(baseline_predictions))



calculateAccuracy(test[["is_spam"]], baseline_predictions, cutoff = baseline_cutoff)

## _Note: you will find the user defined functions in `week10/eval_utils.R`._

Better model performance metric would be AU(RO)C:
baseline_auc <- calculateAUC(
    actual = test[["is_spam"]], predictions = baseline_predictions
)

baseline_auc

baseline_confusion_matrix <- getConfusionMatrix(
    actual = test[["is_spam"]],
    predictions = baseline_predictions,
    cutoff = baseline_cutoff
)

calculateFPRTPR(baseline_confusion_matrix)

### Logit using only numeric features

logit_only_num_feat_model <- glm(
    is_spam ~ sms_chr_length + num_words + num_non_stopwords,
    family = binomial(link = "logit"),
    data = train[, -c("message_id", "sms_text")]
)

logit_only_num_feat_predictions <- predict(
    logit_only_num_feat_model, newdata = test, type = "response"
)

logit_only_num_feat_auc <- calculateAUC(
    actual = test[["is_spam"]], predictions = logit_only_num_feat_predictions
)

calculateROC(
    actual = test[["is_spam"]], predictions = logit_only_num_feat_predictions
) %>%
    plotROC(
        model_name = "logit model using only numeric features",
        auc = logit_only_num_feat_auc
    )

### Logit using all features


## EXERCISE: repeat the above logit model, but now use all features (incl. the one hot encodings!)
# TODO add solution


### Random Forest

## EXERCISE: for 2 bonus points:
## + repeat the full model with RF!
## + Also plot variable importance.
# TODO add solution
