library(data.table)
library(ggplot2)
library(stringr)
library(glmnet)

laptop <- fread("week6/data/laptop_price.csv")

# 0. Setup the project!
# 1. Is the data in the right format? Does it need cleaning?
# 2. Visualize the distributions! Does it need more cleaning?
# 3. Decide on features! Create train and test set!
# 4. Use linear regression to train a model! Evaluate the model!
# 5. Train a model using Ridge or Lasso regression (cross-validation)! Evaluate the models!


# 1. Is the data in the right format? Does it need cleaning?
laptop[, .N, Ram]
laptop[, Ram_numeric := as.integer(gsub("GB", "", Ram))]

laptop[, .N, word(Cpu, 1)]
laptop[, Cpu_type := word(Cpu, 1)]

laptop[, .N, word(Cpu, -1)]
laptop[, Cpu_frequency_str := word(Cpu, -1)]
laptop[, Cpu_frequency := as.numeric(gsub("GHz", "", word(Cpu, -1)))]

laptop[, .N, word(ScreenResolution, -1)]
laptop[, screen_resolution := word(ScreenResolution, -1)]

# 2. Visualize the distributions! Does it need more cleaning
ggplot(laptop, aes(x = Price_euros)) +
        geom_density()

ggplot(laptop, aes(x = log(Price_euros))) +
    geom_density()

laptop %>%
    .[, .(mean_price = mean(Price_euros)), Cpu_type] %>%
    ggplot(aes(x = Cpu_type, y = mean_price)) + geom_col()


ggplot(laptop, aes(x = Cpu_type, y = Price_euros)) +
    geom_boxplot()

ggplot(laptop, aes(x = Ram_numeric, y = Price_euros)) +
    geom_point() +
    ggtitle("Compare price with Ram") +
    labs(x = "RAM in GB", y = "Price in EUR") +
    scale_y_continuous(labels = scales::comma)

# 3. Decide on features! Create train and test set!
set.seed(8797234)
train_index <- sample(1:nrow(laptop), nrow(laptop) * 0.7)
laptop_train <- laptop[train_index]
laptop_test <- laptop[-train_index]

# 4. Use linear regression to train a model! Evaluate the model!
linear_model <- lm(
    Price_euros ~ Cpu_type + Cpu_frequency + Ram_numeric,
    laptop_train
)
summary(linear_model)

laptop_test[, prediction_lm := predict(linear_model, laptop_test)]

laptop_test[, sqrt(sum((Price_euros - prediction_lm)**2) / .N)]

# (NOTE: The following two plots were not covered in class!)
ggplot(laptop_test, aes(x = Price_euros, y = prediction_lm)) +
    geom_point() +
    geom_abline(slope = 1) +
    coord_fixed(xlim = c(0, 5000), ylim = c(0, 5000))
ggplot(laptop_test, aes(x = Price_euros, y = Price_euros - prediction_lm)) + geom_line()

# 5. Train a model using Ridge or Lasso regression (cross-validation)! Evaluate the models!
X <- model.matrix(Price_euros ~ Cpu_type + Cpu_frequency + Ram_numeric, data = laptop_train)[,-1]

set.seed(82394)
ridge <- cv.glmnet(X, laptop_train$Price_euros, alpha = 0, nfolds = 5)
coef(ridge_best)

X_test <- model.matrix(Price_euros ~ Cpu_type + Cpu_frequency + Ram_numeric, data = laptop_test)[,-1]
# This one didn't work, because CPU type "Samsung" was not in the test set, only in the train set.
# This is because there is only 1 observation with Samsung CPU.
# We have an error, because when predicting from LASSO model, the function needs to have the same number of dimensions as an input.
laptop_test[, "prediction_ridge":=predict(ridge, s = "lambda.min", newx =  X_test)]

str(X)
str(X_test)

# To solve this, we have 'cheated' during class, so I can show you the result of the model. 
# This isn't the good solution for this kind of problem!

laptop_test_extended <- rbind(laptop_test, laptop[Cpu_type == "Samsung"], fill = TRUE)

X_test <- model.matrix(Price_euros ~ Cpu_type + Cpu_frequency + Ram_numeric, data = laptop_test_extended)[,-1]
laptop_test_extended[, "prediction_ridge":=predict(ridge, s = "lambda.min", newx =  X_test)]

laptop_test_extended[, sqrt(sum((Price_euros - prediction_ridge)**2) / .N)]

