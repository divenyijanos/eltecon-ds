library(ggplot2)
library(data.table)

# 1. PCA Lab
# This section is based on [James, G., Witten, D., Hastie, T., and Tibshirani, R. 
# *An Introduction to Statistical Learning with Applications in R.*  Pages 401-403.]
# (http://faculty.marshall.usc.edu/gareth-james/ISL/)

?USArrests
head(USArrests)
apply(USArrests, 2, mean)
apply(USArrests, 2, var)

pca_output <- prcomp(USArrests, scale = TRUE)

pca_output$center
pca_output$scale
# ``center`` and ``scale`` are the *means* and *standard deviations* of the variables 
# that were used for scaling prior to implementing PCA

pca_output$rotation
# ``rotation`` is the matrix whose columns contain the Eigenvectors (aka. loadings)

head(pca_output$x)
# matrix ``x`` has as its columns the principal component Score vectors

pca_output$rotation <- -pca_output$rotation
pca_output$x <- -pca_output$x
biplot(pca_output, scale = 0)

# to adjust margins for plotting: par(mar=c(1,1,1,1))
biplot(pca_output, scale = 0)

pca_output$sdev
pca_var <- pca_output$sdev^2
pca_var
pca_var_expl <- pca_var / sum(pca_var)
pca_var_expl
plot(
    pca_var_expl,
    main = "PCA - Proportion of variance explained",
    xlab = "Principal Component", 
    ylab = "Proportion of Variance Explained", 
    ylim = c(0, 1), 
    type = "b"
)

plot(
    cumsum(pca_var_expl),
    main = "PCA - Cumulative Proportion of Variance Explained",
    xlab = "Principal Component", 
    ylab = "Cumulative Proportion of Variance Explained", 
    ylim = c(0, 1), 
    type = "b"
)

# 2. Clustering lab
# This section is based on [James, G., Witten, D., Hastie, T., and Tibshirani, R. 
# *An Introduction to Statistical Learning with Applications in R.*  Pages 404-407.]
# (http://faculty.marshall.usc.edu/gareth-james/ISL/)

## 2.1 K-means clustering with K=2
library(data.table)
library(ggplot2)
set.seed(2)
x <- data.table(a = rnorm(50), b = rnorm(50))
x[1:25, `:=`(a = a + 3, b = b - 4)]

km_output <- kmeans(x, centers = 2, nstart = 20)
km_output
km_output$cluster

ggplot(x, aes(x = a, y = b)) +
    geom_point()

ggplot(x, aes(x = a, y = b)) +
    geom_point(colour = (km_output$cluster + 1), size = 4) 

## K-means clustering with K=3
set.seed(4)
km_output <- kmeans(x, centers = 3, nstart = 20)

ggplot(x, aes(x = a, y = b)) +
    geom_point(colour = (km_output$cluster+1), size = 4) 

## Different `nstart` initial cluster assignments result different total 
# within-cluster sum of squares
set.seed(3)
km_output <- kmeans(x, centers = 3, nstart = 1)
km_output$tot.withinss
km_output <- kmeans(x, centers = 3, nstart = 20)
km_output$tot.withinss
km_output <- kmeans(x, centers = 3, nstart = 50)
km_output$tot.withinss

## How to determine the number of clusters?
# 1. Run K-means with *K*=1, *K*=2, ..., *K*=*n*.
# 2. Record total within-cluster sum of squares for each value of *K*.
# 3. Choose *K* at the *elbow* position.

ks <- 1:5
tot_within_ss <- sapply(ks, function(k) {
    km_output <- kmeans(x, centers = k, nstart = 20)
    km_output$tot.withinss
})
tot_within_ss

## How to determine the number of clusters?    
plot(
    x = ks, 
    y = tot_within_ss, 
    type = "b", 
    xlab = "Values of K", 
    ylab = "Total within cluster sum of squares"
)

## 2.2 Hierachical clustering (using different linkage types)
set.seed(2)
x <- data.table(a = rnorm(50), b = rnorm(50))
x[1:25, `:=`(a = a + 3, b = b - 4)]

# Compute the inter-observation Euclidean distance matrix using `dist()`
# Set the linkage type in the `method` argument
hc_complete <- hclust(dist(x), method = "complete")
hc_average <- hclust(dist(x), method = "average")
hc_single <- hclust(dist(x), method = "single")

## Preparing the dendogram
par(mfrow = c(1, 3))
plot(hc_complete, main = "Complete linkage", xlab = "", ylab = "", sub = "")
plot(hc_average, main = "Average linkage", xlab = "", ylab = "", sub = "")
plot(hc_single, main = "Single linkage", xlab = "", ylab = "", sub = "")

## Determining cluster labels with `cutree()` by selecting `k`
cutree(hc_complete, k = 2)
cutree(hc_average, k = 2)
cutree(hc_single, k = 2)

## Determining cluster labels with `cutree()` by selecting `h`
cutree(hc_complete, h = 2)

cutree(hc_complete, h = 5)
cutree(hc_average, h = 4)
cutree(hc_single, h = 1.4)

## Scale variables with `scale()`
x_scaled <- scale(x)
par(mfrow = c(1, 1))
plot(hclust(dist(x_scaled), method = "complete"), 
     main = "Hierarchical clustering with scaled features")

## Compute correlation-based distance using `as.dist()`
set.seed(5)
x <- matrix(rnorm(30 * 3), ncol = 3)
dd <- as.dist(1 - cor(t(x)))

## Compute correlation-based distance using `as.dist()`
plot(hclust(dd, method = "complete"), 
     main = "Complete linkage with correlation-based distance",
     xlab = "", sub = "")
