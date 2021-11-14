library(data.table)
library(ggplot2)
library(magrittr)
library(tidytext)


## Task 1
marvel_reviews_raw <- fread("week8/data/marvel_reviews_raw.csv")

marvel_reviews <- marvel_reviews_raw %>%
    .[, media_score := as.integer(gsub("%", "", media_score))] %>%
    .[, main_actor := stringr::str_match(cast, "^(.+), .+, .+$")[, 2]]
    # alternatively w/ gsub:
    # .[, main_actor := gsub(", .+, .+$", "", cast)]

sentiment_scores <- tidytext::get_sentiments(lexicon = "bing") %>%
    data.table() %>%
    .[, sentiment := ifelse(sentiment == "positive", 1, -1)]

movie_review_sentiments <- marvel_reviews %>%
    .[, .(title, short_review)] %>%
    unnest_tokens(input = "short_review", output = "word", drop = FALSE) %>%
    merge(sentiment_scores, by = "word") %>%
    .[, .(movie_review_sentiment_score = sum(sentiment)), by = c("title")]

actor_scores <- marvel_reviews %>%
    .[, .(main_actor, title, media_score)] %>%
    unique() %>%
    merge(movie_review_sentiments, by = c("title")) %>%
    .[, .(
            avg_media_score = mean(media_score),
            avg_review_sentiment = mean(movie_review_sentiment_score)
        ),
        by = "main_actor"
    ]

plot <- ggplot(
    actor_scores,
    aes(x = avg_review_sentiment, y = avg_media_score, label = main_actor)
) +
    geom_smooth(method = "lm", se = FALSE) +
    geom_point() +
    labs(
        title = "Actors' movie review sentiments and media scores",
        subtitle = "Based on the MCU movies as of 2021-11-14",
        caption = paste(
            "Data gathered from rottentomatoes.com",
            "Sentiment lexicon used: 'bing'",
            sep = "\n"
        )
    ) +
    ylim(c(0, 100)) +
    theme_minimal()

plot

plot + ggrepel::geom_text_repel()
