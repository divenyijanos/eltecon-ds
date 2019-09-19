library(data.table)
library(ggplot2)
library(magrittr)

student <- fread("teaching/Drive/eltecon_datatable/student-data.csv")

summary(student)
student[, television := as.numeric(television)]

student[, .N, male]
student[, .N, age][order(age)]

student <- student[beer != 211212000000 | is.na(beer)]

convertMHeightToCm <- function(student) {
  student[height >= 1.3 & height <= 2.1, height := height * 100]
}

clearUnreliableHeight <- function(student) {
  student[height < 100 | height > 230, height := NA]
}

clearUnreliableFood <- function(student) {
  student[food < 100 | food > 10^6, food := NA]
}

clearUnreliableBeer <- function(student) {
  student[beer < 0 | beer > 100, beer := NA]
}

convertMHeightToCm(student)
clearUnreliableHeight(student)
clearUnreliableFood(student)
clearUnreliableBeer(student)


ggplot(student, aes(height, weight)) + geom_point()
ggplot(student, aes(height, weight)) + geom_point() + facet_wrap(~ as.factor(male))


melt(student, measure.vars = c("food", "beer", "television")) %>%
  ggplot(aes(value)) + geom_histogram(bins = 10) +
  facet_wrap(~ variable, scales = "free_x")
