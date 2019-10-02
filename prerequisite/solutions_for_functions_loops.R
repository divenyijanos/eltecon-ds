library(data.table)

# Functions - exercise 1
countNumberOfCharacters <- function(str) {
    str_length <- nchar(str)

    cat(paste(paste0("'", str, "' --> length: ", str_length), collapse = "\n"))
}

# Functions - exercise 2
performStrangeCalculation <- function(x, y, sum_then_multiply = TRUE) {

    if (!(is.numeric(x) & is.numeric(y))){
        stop("Both x and y should be numeric vectors")
    }

    if (sum_then_multiply == TRUE){
        result <- sum(x) * sum(y)
    } else {
        result <- sum(x * y)
    }

    result
}

# Loops - exercise 1
dt <- data.table(
    a = c(1, NA, NA, 5, 2),
    b = c(NA, NA, 4, 5, 6),
    c = c(letters[1:5]),
    d = rep(NA_character_, 5)
)

summarizeNAs<- function(dt) {
    dt[, lapply(.SD, function(x) sum(is.na(x)))]
}

summarizeNAs(dt)

# Loops - exercise 2
set.seed(123)
three_rounds_won <- FALSE
rounds_won <- 0
while(!three_rounds_won) {
    dice_rolls <- sample.int(n = 6, size = 4, replace = TRUE)
    print(paste("Rolls in round:", paste(dice_rolls, collapse = ", ")))
    if(uniqueN(dice_rolls) < 4) {
        rounds_won <- rounds_won + 1
    }
    if(rounds_won >= 3) {
        three_rounds_won <- TRUE
    }
}
