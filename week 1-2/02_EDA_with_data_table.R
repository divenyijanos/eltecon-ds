library(data.table)

student <- fread("week 1-2/data/student-data.csv")

summary(student)

View(student)

student[, .N, male]
student[, .N, age][order(age)]

student <- student[beer != 211212000000 | !is.na(beer)]

convertMHeightToCm <- function(student) {
  student[height >= 1.5 & height <= 2.1, height := height * 100]
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
