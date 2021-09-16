
library(data.table)
library(magrittr)
library(ggplot2)

student_data <- fread("week2/data/student-data.csv")

ggplot(student_data, aes(x = male)) + geom_bar()

student_data[, male := factor(male, labels = c("female", "male"))]

ggplot(student_data, aes(x = male)) + geom_bar()

ggplot(student_data, aes(x = height)) + geom_histogram()

ggplot(student_data, aes(x = height)) + geom_freqpoly()

ggplot(student_data, aes(x = weight, y = height)) + geom_point()

ggplot(student_data, aes(x = weight, y = beer)) + geom_point()

p <- student_data[beer < 300] %>%
    ggplot(aes(x = weight, y = beer, color = male)) +
    geom_point() +
    labs(
        title = "Beer consumption vs weight",
        subtitle = "Segmented by gender",
        y = "Liters per week"
    )

ggplotly(p)

manhattan[(sale_price < 10^7) & (tax_class_at_present == c("1", "1A", "1C"))] %>%
    ggplot(aes(x = sale_price)) +
    geom_density() +
    facet_wrap(~tax_class_at_present, ncol = 1)


# other examples (not covered in class)

student_data[height > 150, .(mean_height = mean(height)), .(male = factor(male, labels = c("female", "male")))] %>%
  ggplot(aes(x = factor(male), y = mean_height)) +
  geom_col()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) +
  geom_boxplot()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) +
  geom_violin()

ggplot(student_data[height > 150], aes(x = factor(male, labels = c("female", "male")), y = height)) +
  geom_jitter() +
  labs(title = "Distribution of height by gender (in meter)", x = NULL, y = NULL) +
  scale_y_continuous(limits = c(150, 210), breaks = seq(150, 210, 20)) +
  theme_minimal()

manhattan <- read_excel("week2/data/rollingsales_manhattan.xlsx", skip = 4) %>% data.table()

names(manhattan)
names(manhattan) <- gsub(" ", "_", names(manhattan)) %>% tolower()

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
