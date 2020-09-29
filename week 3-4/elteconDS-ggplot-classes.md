# 1st class

- homework presentation
    + Kovács Ádám - Nguyen Nam Son 
    + Bakirov, Aslan - Yatsenko, Anzhelika
    + Both Márton - Kamenár Gyöngyvér
- How ggplot2 works
    + transform your data (x axis defines an observation in the data, y axes the values)
    + map your data to aesthetics (explain what this means)
    + configure the plot
    + Think in layers
- Examples of simple plotting
    + line chart, bar chart, scatter plot (no transformation in the ggplot func call.)
    + Show what's the diff. when color='blue' in and out of the aes() call.
    + histogram, density, geom_col, etc. (plots w/ tranformation)
    + Additional: add extra lines (hline, vline)
    + Add text
- Configure the plot (most important ones)
    + labs: title, subtitle, axis labs, caption
    + coordinates, limits, 1:1, scales
    + formatting the numbers on the chart
    + num ticks
- Other
    + How to save a plot
    + Facets
- How to debug
    + Search: "R ggplot2 'what you are looking for' "
- Resources: cheat-sheet, [quick reference](https://ggplot2.tidyverse.org/reference/) and Hadley Wickham's book chapters: [this](https://r4ds.had.co.nz/data-visualisation.html) and [this](https://r4ds.had.co.nz/graphics-for-communication.html).
- Homework and presenters next time
    + Emerson, Ian - Ralbovszki Judit
    + Bat-Erdene, Boldmaa - Kashirin, Andrey
    + Kim Yeonggyeong - Im Seongwon




# 2nd class
- how to load your data in your homework
- Homework presentation
    + Emerson, Ian - Ralbovszki Judit
    + Bat-Erdene, Boldmaa - Kashirin, Andrey
    + Kim Yeonggyeong - Im Seongwon
- Quick reminder:
    + `ggplot(data = <DATA>) + <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))`
        * map your data columns to parts of the plot in `aes`
    + https://ggplot2.tidyverse.org/reference
- missed from 1st class (this will be the first part of the class)
    + with ggplot you can do the same thing in multiple ways (e.g. provide data in `ggplot` or in the `geom_*` OR provide a title in `ggtitle` or in `labs`). Try to stick to one only.
    + Multiple data on one chart
    + themes
    + how to manage colors (and factors)
    + patchwork to put plots next to each other
    + Parts of the plot as a list
- First class: from a table to a plot (, to a nicer plot), Second class: from a plot to a plot that makes sense
- When to choose a plot? (https://www.t4g.com/insights/data-visualization-good-choice/)
    + If it's easy to form the message in a sentence, just write it down.
    + Use a table if
        * To compare or communicate specific values rather than a trend
        * To compare pairs of numbers
        * To include both summary and detailed numbers
        * To communicate sets of numbers that have different units
- [GO OVER THE RSTUDIO CONF presentation on visualisation]
- The message: a plot should have one easy-to-understand message (you can include that message in the title or caption too!)
- The workflow, working our way backwrards:
    + What should be the message of the plot? What objective do you want to achieve? What question do you want to answer? [GIVE EXAMPELS HERE of possible objectives]
    + What data do I need to do that? (Do I have the data for that?) (You can transorm your data at this point!)
        * Think of columns
        * but also about filters: date e.g.
    + What plot type will best convey the message to the recipient? (Think about who is the recipient!)
    + Now figure out what colors, lines and other attribute will best suite your plot! Also, put enough verbal information on your plot so it's easy to read but keep it as low as possible because that increases the mental load when processing the image.
    + When you are ready, ask yourself: Does this plot convey the message? Get some distance from your plot and realize that the recipient might not know your data as well as you do!
- What to consider when you want to convey the message?
    + Plot type choice
    + Color choice
    + Simplicity
- Examples of the above
    + https://r4ds.had.co.nz/data-visualisation.html#geometric-objects
- Output types:
    + ".png" / ".jpg"
    + Rmarkdown
    + Plotly
    + Shiny
- Extensions: https://exts.ggplot2.tidyverse.org/gallery/
- Why visualization is important?
    + You'll use it for communicating your results most of the time
- Homework presentation for next class
    + Szőnyi Máté - Trần, Dung
    + Sármány Áron - Schmall Róbert
    + Alexandrov Dániel - Földesi Attila


#### Multiple data on one chart

```{r}
hwy_class_avgs <- mpg[, .(hwy_class_avg = mean(hwy)), by = class]

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
    geom_jitter() +
    geom_text(data = hwy_class_avgs, mapping = aes(y = hwy_class_avgs, label = hwy_class_avgs))
```
