library(data.table)
library(magrittr)
library(ggplot2)
library(skimr)

# Clean
students <- fread("week 11-12/data/student-data.csv")
skim(students)

students[order(height)]
clean_students <- students[, 
    television := as.numeric(television)
][
    television <= 1000,
][
    height < 150, height := NA
][
    weight < 30, weight := NA
][
    food > 10^6, food := NA
][
    beer > 100, beer := NA
]
    
skim(clean_students)
students_full <- na.omit(clean_students)

# Cluster
kmeans3 <- kmeans(scale(students_full), 3, nstart = 10)
students_full[, cluster := kmeans3$cluster]
students_full[, lapply(.SD, mean), cluster]

melt(students_full, id.vars = "cluster") %>%
    ggplot(aes(factor(cluster), value)) + geom_boxplot() + facet_wrap(~ variable, scales = "free")


# Hierarchical clustering

distances <- dist(scale(students_full))
hclusters <- hclust(distances)
plot(hclusters)
students_full[, hcluster := cutree(hclusters, k = 3)]

students_full[, lapply(.SD, mean), cluster]
students_full[, lapply(.SD, mean), hcluster]
