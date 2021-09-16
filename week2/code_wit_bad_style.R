not_nice_object_name <- c(1:10)
anotherNotNiceObjectName <- c(10:20)

myFunction <- function(arg1, arg2) {
  foo <- sum(arg1) + sum(arg2)
  foo + 2
}

result <- myFunction(notNiceObjectName, anotherNotNiceObjectName)

# Use lintr::lint("code.R") to check the style of your code.

# Use styler::style_file("code.R") to reformat your file
# or styler::style_dir() to all R codes in a directory.
