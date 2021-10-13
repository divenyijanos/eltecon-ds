# some updates

library(data.table)

# What is wrong with this code?
dt <- fread("~/project/eltecon-ds/week6/data/laptop_price.csv")

dt[, .N]

# FYI `~` is shorthand for home directory on Mac (and Linux systems also).
# So in my case it is the same as `/Users/i525640`

# What is wrong with this code?
setwd("~/project/eltecon-ds/week6")

dt <- fread("data/laptop_price.csv")

dt[, .N]

# What is the proper way? Create your project with R project!
# We use this one at Emarsys (without `here` package).


# Optionally, use the `here package!

# If you have an R project set in your project,
# here will set the working directory to where the .Rproj file is!

library(here)

dt <- fread(here("week6", "data", "laptop_price.csv"))

dt[, .N]
