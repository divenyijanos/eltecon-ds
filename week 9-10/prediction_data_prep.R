library(data.table)

#Read in data
data <- fread('week 9-10/data/OnlineNewsPopularity.csv')
data <- data[data$n_unique_tokens != 701,]
var.names <- names(data)
x.time <- var.names[c(2,32:39)]
data <- data[,-x.time, with = FALSE]
data <- data[, constant := 1]
fwrite(data, 'week 9-10/data/OnlineNewsPopularity_mod.csv')
