### setup ——————————————————————————————————————————————————————————————————————

setwd("week 3-4")

install.packages("ggplot2")
install.packages("data.table")
library(ggplot2)
library(data.table)

theme_set(theme_minimal())

### data ———————————————————————————————————————————————————————————————————————

# sales <- fread("data/sales_sample.csv") %>%
#     .[sample(1:300)] %>%
#     .[, purchase_date := as.Date(purchase_date)] %>%
#     .[sales_amount %between% c(0, 250) & quantity %between% c(0, 15)]

# head(sales)

# mpg: milage per gallon
mpg <- unique(as.data.table(mpg))
head(mpg)
?mpg
nrow(mpg)


### Examples of simple plotting ————————————————————————————————————————————————

# always start with the data transformed to your needs
# then add the ggplot func. call with the data
# and finally add one or more layers

ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy))

mpg_agg <- mpg[, .(avg_displ = mean(displ)), by = drv]
ggplot(data = mpg_agg) +
    geom_col(mapping = aes(x = drv, y = avg_displ))

mpg_agg <- mpg[, .(avg_cty = mean(cty)), year]
ggplot(data = mpg_agg) +
    geom_line(mapping = aes(x = year, y = avg_cty, group = 1))


### Adding more than just X and Y variables ————————————————————————————————————

ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = drv))

# see what happens if you add the color param outside of the mapping function
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = drv), color = "blue")

# the following wouldn't really make sense
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, size = drv))

# use alpha to see through
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, size = drv), alpha = .3)

# but this would
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, shape = drv), alpha = .3)


### Adding extra lines —————————————————————————————————————————————————————————

# ab line
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy)) +
    geom_abline(slope = 1, intercept = 0, color = "red")
# mention hline/vline

# linear regression line
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy)) +
    geom_smooth(mapping = aes(x = cty, y = hwy), method = "lm")

### Facets —————————————————————————————————————————————————————————————————————

ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy), alpha = .3) +
    facet_wrap(~drv)

ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy), alpha = .3) +
    facet_wrap(~drv, ncol = 1)

ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = fl)) +
    facet_wrap(~drv, ncol = 1)
# too much info?


### Plots where data aggregation happens while plotting ————————————————————————

# histogram
ggplot(data = mpg) +
    geom_histogram(mapping = aes(x = hwy))

ggplot(data = mpg) +
    geom_bar(mapping = aes(x = fl))
# Where does count come from?

ggplot(data = mpg) +
    geom_bar(mapping = aes(x = fl, y = stat(prop), group = 1))

ggplot(data = mpg) +
    geom_boxplot(mapping = aes(x = manufacturer, y = hwy))


### Beautifing the plot ————————————————————————————————————————————————————————

# labels
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = class)) +
    ggtitle("Vehicle fuel consumption: city vs. highway") +
    labs(
        title = "Vehicle fuel consumption: city vs. highway",
        subtitle = "City vs. Highway",
        x = "City",
        y = "Highway",
        color = "Type of car",
        caption = "Fuel consumption is shown in milage per gallon (mpg)"
    ) +
    coord_fixed()

# coord flip
ggplot(data = mpg) +
    geom_boxplot(mapping = aes(x = manufacturer, y = hwy))

ggplot(data = mpg) +
    geom_boxplot(mapping = aes(x = manufacturer, y = hwy)) +
    coord_flip()

# scales: breaks and labels
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = class)) +
    scale_y_continuous(breaks = seq(0, 45, by = 5)) +
    scale_x_continuous(labels = function(x) paste(x, "m/g"))


# zooming
ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = class)) +
    coord_cartesian(xlim = c(15, 20), ylim = c(25, 30))

# saving your graph
my_plot <- ggplot(data = mpg) +
    geom_point(mapping = aes(x = cty, y = hwy, color = class))

# you can skip the 'plot = ' part
ggsave("figures/my_plot.png", plot = my_plot)
