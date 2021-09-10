library(data.table)
library(magrittr)
library(readxl)
library(ggplot2)

# Import the data

# manhattan <- fread("week2/data/rollingsales_manhattan_cleaned.xlsx")
# manhattan <- read.csv("week2/data/rollingsales_manhattan.xlsx", skip = 4) %>% data.table()
manhattan <- read_excel("week2/data/rollingsales_manhattan.xlsx", skip = 4) %>% data.table()

names(manhattan)
names(manhattan) <- gsub(" ", "_", names(manhattan)) %>% tolower()


# Are the columns in the right format?

str(manhattan)

# Example to show what if a column is not in right format
manhattan[, sale_date_str := as.character(sale_date)]
manhattan[, sale_date_str := as.POSIXct(sale_date)]
manhattan[, sale_date_str := NULL]


# Check basic distribution of features! Do they make sense?

summary(manhattan)

manhattan[, .N, neighborhood]
manhattan[, .N, building_class_category]
manhattan[, .N, tax_class_at_present]
manhattan[, .N, block]

manhattan[, lapply(.SD, uniqueN)]

manhattan[, lapply(.SD, function(x) sum(is.na(x)))]

manhattan[, easement := NULL]

manhattan[, .N, keyby = total_units]


# Visualize features

ggplot(manhattan, aes(x = sale_price)) + geom_histogram()

manhattan[, .N, sale_price == 0]

# Sale price
ggplot(manhattan[sale_price > 0], aes(x = sale_price)) + geom_histogram()
ggplot(manhattan[sale_price > 0], aes(x = sale_price)) + geom_histogram(bins = 100)

ggplot(manhattan, aes(x = sale_price)) +
    geom_freqpoly() +
    xlim(c(0, 10^7))

ggplot(manhattan, aes(x = sale_price)) +
    geom_freqpoly(aes(y = (..count..)/sum(..count..))) +
    xlim(c(0, 10^7))

ggplot(manhattan, aes(x = sale_price)) +
    stat_ecdf() +
    xlim(c(0, 10^7))

# Total unit, residential unit, commercial unit
manhattan[commercial_units + residential_units != total_units]

melt(manhattan, measure.vars = c("residential_units", "commercial_units", "total_units")) %>%
    ggplot(aes(x = value)) +
    geom_freqpoly() +
    facet_wrap(~variable, ncol = 1)

melt(manhattan, measure.vars = c("residential_units", "commercial_units", "total_units")) %>%
    ggplot(aes(x = value)) +
    geom_freqpoly() +
    xlim(c(0, 100)) +
    facet_wrap(~variable, ncol = 1)

# Year built
ggplot(manhattan, aes(year_built)) + geom_histogram()

# Sale date
ggplot(manhattan, aes(year_built)) + geom_histogram()


# Which features would be useful for predictin sale price?

ggplot(manhattan, aes(x = as.factor(month(sale_date)), y = sale_price)) +
    geom_boxplot() +
    ylim(c(0, 10^7))

ggplot(manhattan, aes(x = sale_price, y = gross_square_feet)) +
    geom_point()

ggplot(manhattan, aes(x = sale_price, y = gross_square_feet)) +
    geom_point() +
    xlim(c(10^4, 10^9))

ggplot(manhattan, aes(x = sale_price, y = gross_square_feet)) +
    geom_point()
    scale_x_log10()

ggplot(manhattan, aes(x = sale_price, y = (land_square_feet))) +
    geom_point() +
    scale_x_log10()

manhattan[, .(avg_sale_price = mean(sale_price), n = .N), tax_class_at_present] %>%
    ggplot(aes(x = tax_class_at_present, y = avg_sale_price)) +
    geom_col() +
    geom_text(aes(label = paste0("Num obs:\n", n), vjust = -0.5))

