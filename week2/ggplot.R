library(ggplot2)
library(data.table)
library(magrittr)

student_data <- fread("week2/data/student-data.csv")

ggplot(student_data, aes(x = male)) + geom_bar()

ggplot(student_data, aes(x = age)) + geom_bar()

ggplot(student_data, aes(x = age, fill = as.character(male))) +
    geom_bar()

ggplot(student_data, aes(x = age, fill = as.character(male))) +
    geom_bar(position = "dodge")

ggplot(student_data, aes(x = age, fill = as.character(male))) +
    geom_histogram(bins = 10, position = "dodge")

ggplot(student_data, aes(x = age, color = as.character(male))) +
    geom_freqpoly(bins = 10)

ggplot(student_data, aes(x = age)) + geom_density()

ggplot(student_data, aes(x = age, color = as.character(male))) + geom_density()

ggplot(student_data, aes(x = height)) + geom_density()

ggplot(student_data, aes(x = height)) + geom_density()

ggplot(student_data, aes(x = height, fill = as.character(male))) + geom_density()

ggplot(student_data, aes(x = height, color = as.character(male))) + geom_freqpoly()

ggplot(student_data[food < 10^5], aes(x = food)) + geom_density()

ggplot(student_data[height > 150], aes(x = height, y = weight, color = as.factor(male))) + geom_point()

ggplot(student_data[height > 150], aes(x = height, y = weight, color = as.factor(male))) + geom_point()

ggplot(student_data[height > 150], aes(x = as.factor(male), y = weight)) + geom_point()

student_data[height > 150, .(mean_height = mean(height)), .(male = factor(male, labels = c("female", "male")))] %>%
    ggplot(aes(x = factor(male), y = mean_height)) + geom_col()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) + geom_boxplot()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) + geom_violin()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) + geom_jitter()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) +
    geom_jitter() +
    labs(title = "Distribution of height by gender (in meter)", x = NULL, y = NULL) +
    scale_y_continuous(limits = c(150, 210), breaks = seq(150, 210, 20)) +
    theme_minimal()

manhattan <- read_excel("week2/data/rollingsales_manhattan.xlsx", skip = 4) %>% data.table()

names(manhattan)
names(manhattan) <- gsub(" ", "_", names(manhattan)) %>% tolower()

ggplot(manhattan[sale_price < 10^7], aes(x = sale_price)) +
    geom_density() +
    facet_wrap(~tax_class_at_present)

manhattan[sale_price < 10^7 & tax_class_at_present %in% c("1", "1A", "1C")] %>%
    ggplot(aes(x = sale_price)) +
    geom_density() +
    facet_wrap(~tax_class_at_present, ncol = 1) +
    scale_x_continuous(labels = scales::dollar)

student_data[, television := as.numeric(television)]
ggplot(student_data[television < 1000 & beer < 400], aes(x = beer, y = television)) +
    geom_point() +
    geom_smooth(method = "lm")

library(ggtext)
student_data[beer < 400] %>%
    ggplot(aes(x = beer, fill = factor(male, labels = c("female", "male")))) +
    geom_histogram(position = "dodge", bins = 5) +
    labs(
        title = "Difference in beer consumption between <span style = 'color: red'>females</span> and <span style = 'color: lightblue'>males</span>",
        x = "Liters per week", y = "Num. person"
    ) +
    theme_minimal() +
    theme(
        text = element_text(size = 20),
        legend.position = "None",
        plot.title = element_markdown()
    )

cols <- c("female" = "red", "male" = "lightblue")
student_data[beer < 400] %>%
    .[, male := factor(male, labels = c("female", "male"))] %>%
    ggplot(aes(x = beer, fill = male)) +
    geom_histogram(position = "dodge", bins = 5) +
    labs(
        title = "Difference in beer consumption between <span style = 'color: red'>females</span> and <span style = 'color: lightblue'>males</span>",
        x = "Liters per week", y = "Num. person"
    ) +
    theme_minimal() +
    theme(
        text = element_text(size = 20),
        legend.position = "None",
        plot.title = element_markdown()
    ) +
    scale_fill_manual(values = cols)

library(plotly)
p <- ggplot(manhattan, aes(x = year_built, y = sale_price, label = address)) +
    geom_point() +
    ggtitle("Year built vs sale price", subtitle = "for houses in Manhattan")
ggplotly(p)
