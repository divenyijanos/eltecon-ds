# install.packages("data.table")
# install.packages("ggplot2")


### Setup ——————————————————————————————————————————————————————————————————————

library(data.table)
library(ggplot2)

mpg <- unique(as.data.table(ggplot2::mpg))


# Themes ------------------------------------------------------------------

ggplot(mpg) +
    geom_jitter(aes(cty, hwy)) +
    theme_light()


# Managing colors when plotting factors -----------------------------------

mpg$class %>% unique()
mpg$class %>% class()

mpg[, class := factor(class, levels = c("midsize", "compact", "suv", "2seater", "minivan", 
                                        "pickup", "subcompact"))]

ggplot(data = mpg) +
    geom_bar(mapping = aes(x = class, fill = class)) +
    scale_fill_manual(
        values = c("blue", "green", "red", "yellow", "black", "magenta", "white"),
        labels = 1:7
    )

ggplot(data = mpg) +
    geom_bar(mapping = aes(x = class, fill = class)) +
    scale_fill_brewer(palette = "YlOrRd")



# Multiple graphs on the same plot ----------------------------------------

# install.packages("patchwork")
library(patchwork)

p1 <- ggplot(data = mpg) +
    geom_bar(mapping = aes(x = class, fill = class)) +
    scale_fill_manual(
        values = c("blue", "green", "red", "yellow", "black", "magenta", "white"),
        labels = 1:7
    )

p2 <- ggplot(data = mpg) +
    geom_bar(mapping = aes(x = class, fill = class)) +
    scale_fill_brewer(palette = "YlOrRd")

p1 + p2

p3 <- ggplot(mpg) +
    geom_jitter(aes(cty, hwy)) +
    theme_light()

(p1 | p2) /
    p3

# Returning layers in a function ------------------------------------------

ggplot(mpg) +
    geom_bar(aes(x = class, fill = class))


setPlotAes <- function(palette, title, ylimmax) {
    list(
        scale_color_brewer(palette = palette),
        ggtitle(title),
        coord_cartesian(ylim = c(0, ylimmax))
    )
}

ggplot(mpg) +
    geom_bar(aes(x = class, fill = class)) +
    setPlotAes(3, "Not bad either!", 120)


# The data behind the plots -----------------------------------------------

p <- ggplot(mpg) +
    geom_histogram(aes(hwy))

pd <- ggplot_build(p)

pd$data[[1]]


# plotly ------------------------------------------------------------------

install.packages("plotly")
library(plotly)

ggplotly(
    ggplot(mpg) +
        geom_bar(aes(x = class, fill = class)) +
        setPlotAes(3, "Not bad either!", 120)
)
