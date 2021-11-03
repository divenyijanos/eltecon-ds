library(data.table)
library(ggplot2)
library(magrittr)
library(tidytext)

## Exercise 1: Capture the movie's id in the following string!

movie_url <- "https://www.rt.com/m/1003722-casino_royale"

# Expected answer: "1003722-casino_royale"



## W/ capturing groups

movie_urls <- c(
    "https://www.rt.com/m/1003722-casino_royale",
    "https://www.rt.com/m/1003722-casino_royale/reviews",
    "https://www.rt.com/m/1003722-casino_royale/reviews?type=top_critics",
    "https://www.rt.com/m/1003722-casino_royale/pictures"
)

stringr::str_match(
    string = movie_urls, pattern = ".*/m/(.+?)(/.*)?$"
)


# Hint: use https://regex101.com/ if needed!

img_url <- "https://resizing.flixster.com/R1dBRE4KaDM5WfvLIS7-0aSZMIo=/206x305/v2/https://flxt.tmsimg.com/assets/p4248_p_v8_ad.jpg"

stringr::str_match(
    string = img_url,
    pattern = ".+/(https://.+\\.jpg)"
)[, 2]


## Exercise 2: Tokenize reviews & count the 10 most frequent words!

reviews <- fread("week8/data/james_bond_007_franchise_short_reviews.csv") %>%
    .[, .(movie_title, media_score, short_review)]


## Exercise 3: Remove bigrams that have the first or second word on the stopword list!

review_bigrams_by_movie <- reviews %>%
    .[, .(short_review)] %>%
    tidytext::unnest_tokens(
        output = bigram,
        input = short_review,
        token = "ngrams", n = 2
    )


## Sentiment analysis

sentiment_scores <- tidytext::get_sentiments(lexicon = "afinn") %>% data.table()

review_sentiment_scores <- reviews[, .(short_review)] %>%
    tidytext::unnest_tokens(output = word, input = short_review, drop = FALSE) %>%
    merge(sentiment_scores, by = "word") %>%
    .[, .(sentiment_score = sum(value)), by = c("short_review")]

review_sentiment_scores[order(-sentiment_score)] %>% View()
review_sentiment_scores[order(-sentiment_score)] %>% View()
