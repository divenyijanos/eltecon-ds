library(data.table)
library(ggplot2)
library(magrittr)
library(caret)

arrests <- as.data.table(USArrests)
skimr::skim(arrests)

# Principal Component Analysis
arrests_scaled <- as.data.table(scale(arrests))
skimr::skim(arrests_scaled)

pca <- prcomp(arrests_scaled)

pca$sdev / sum(pca$sdev)
pca$rotation


arrests_scaled_2d <- arrests_scaled[, .(Murder, Assault)]
pca_2d <- prcomp(arrests_scaled_2d)

pca_2d$sdev / sum(pca_2d$sdev)


pca_2d_pc1 <- pca_2d$rotation[, 1]
ggplot(arrests_scaled_2d, aes(Murder, Assault)) + geom_point() +
    geom_abline(
        slope = pca_2d_pc1[["Assault"]]/pca_2d_pc1[["Murder"]], 
        color = "Blue"
    ) +
    geom_abline(
        slope = coef(lm(Assault ~ Murder, data = arrests_scaled_2d))[["Murder"]], 
        color = "Red"
    )

# apply PCA in a prediction task
data <- ISLR::Hitters
skimr::skim(data)
hitters <- as.data.table(data)[!is.na(Salary)]

pca_hitters <- prcomp(scale(hitters[, -c("Salary", "NewLeague", "League", "Division")]))
cumsum(pca_hitters$sdev / sum(pca_hitters$sdev))

set.seed(20201202)
lm_fit <- train(
    Salary ~ .,
    data = hitters,
    method = "lm",
    trControl = trainControl(method = "cv", number = 5),
    preProcess = c("center", "scale")
)

set.seed(20201202)
lm_fit_pca_full <- train(
    Salary ~ .,
    data = hitters,
    method = "lm",
    trControl = trainControl(method = "cv", number = 5, preProcOptions = list(pcaComp = 19)),
    preProcess = c("center", "scale", "pca")    
) # we get exactly the same result as we use all of the principal components

set.seed(20201202)
lm_fit_pca <- train(
    Salary ~ .,
    data = hitters,
    method = "lm",
    trControl = trainControl(method = "cv", number = 5, preProcOptions = list(pcaComp = 11)),
    preProcess = c("center", "scale", "pca")    
)
lm_fit_pca_fullg
lm_fit_pca

# Optimize for number of components to use from PCA
tune_grid <- data.frame(ncomp = 1:19)
set.seed(20201202)
lm_fit_pca_tuned <- train(
    Salary ~ .,
    data = hitters,
    method = "pcr",
    trControl = trainControl(method = "cv", number = 5),
    tuneGrid = tune_grid,
    preProcess = c("center", "scale")    
)
lm_fit_pca_tuned
