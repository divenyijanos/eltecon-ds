# Tasks for 2020-09-30, Part 1

> You can do the following exercises using the data you have already chosen. Make sure to save your work (the code) b/c you will use it in Part 2 and will also need to send it to me alongside your homework! (It won't be graded but I want to see what's going more and what's going less well.)

1. Plot a line chart using your data (e.g. time on the X axis, some value on the Y)!
If you don't have time series data you should choose some other continuous variable for X and order it. 
    1. The line chart should contain multiple lines with different colors (I briefly mentioned last time that for this you'll need to use the `group` parameter within `aes()` to tell ggplot which points it should connect together and which it shouldn't.)
    1. Add a theme which was not covered during class
    1. Convert the categorical variable (the one used for coloring) to factor
    1. Use different colors than the default
    1. Add different labels to your colors than the default

1. Print the first 6 rows of the above plot's underlying data

1. Create a function that extends your previous plot and which will add title and subtitle to it which are provided as function parameters!

1. Create one more simple plot (can be the simplest you can do)
    1. use `{patchwork}` to put the two plots together in one plot
    1. Also use the function from the previous task

1. Optional, difficult task: Create a function which will plot a histogram. (You can submit this task also as part of your homework. Say your homework would score 1 point out of 2, this task can give you the missing +1 score.)
    1. Input parameters should be the data and the variable you want to plot (This is somewhat hard and we didn't cover it in the class. Look up and try `aes_string()` for one alternative! It's a big step forward in R programming if you understand the difference between `aes()` and `aes_string()`. You might come across the phrase *standard / non standard evaluation* during your search. That being said it's completely OK not to understand these concepts just yet, you can still solve the problem!)
    1. Plot twist (face palm): The plot should consist of a subtitle which tells us whether the plot ranges above 40 or not. (E.g. plot a histogram of `mpg$hwy` and `mpg$cty`. One of them should range above and one below 40 (m/g).)
    1. Note, that this function should also work when we "zoom in" on the plot using `coord_cartesian()`, so you can't decide the range before the actual plotting! If you have no idea what I'm talking about skim through the class notes (in the shared folder) where you'll probably find a hint.
    1. Please don't spend too much time on this if you get stuck. Do submit it even if you don't fully solve the problem. Try breaking it down to smaller, possibly independent problems.
