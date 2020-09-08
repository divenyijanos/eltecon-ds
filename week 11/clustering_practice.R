library(data.table)
library(ggplot2)
library(magrittr)

sales_data_raw <- fread("data/sales_data_for_eltecon_ds.csv.gz") 
sales <- sales_data_raw[quantity > 0]
refunds <- sales_data_raw[quantity < 0]
sales_data_clean <- merge(
    sales,
    refunds,
    by = c("customer_id", "si_contact_id", "order_id", "product_id",
           "item_id", "event_time"),
    all.x = TRUE
) %>% 
    .[is.na(price.y)] %>% 
    .[, purchase_date := as.Date(event_time)] %>% 
    .[, .(si_contact_id, product_id, event_time, quantity.x, price.x)] %>% 
    setnames(c("si_contact_id", "event_time", "quantity.x", "price.x"), 
             c("user_id", "purchase_time", "quantity", "price")) %>% 
    unique()
# fwrite(sales_data_clean, file = "data/sales_data_for_clustering.csv")
https://drive.google.com/open?id=1Mg4kMmIc8y0JHtJIkXx33JKbwgDdTImw

# kmeans 1
dt_for_km <- sales_data_clean %>% 
    .[, .(monetary = sum(price, na.rm = TRUE), frequency = uniqueN(purchase_time)),
      by = user_id]
set.seed(4)
km_output <- kmeans(dt_for_km, centers = 3, nstart = 20)
ggplot(dt_for_km, aes(x = monetary, y = frequency)) +
    geom_point(colour = (km_output$cluster + 1), size = 4) 














# kmeans 2
dt_for_km <- sales_data_clean[, 
                              .(price = median(price, na.rm = TRUE), 
                                quantity = median(quantity, na.rm = TRUE)),
                              by = product_id] %>% 
    .[quantity < 10 & price < 6000] %>% 
    .[, product_id := NULL]

set.seed(4)
km_output <- kmeans(dt_for_km, centers = 3, nstart = 20)
ggplot(dt_for_km, aes(x = price, y = quantity)) +
    geom_point(colour = (km_output$cluster+1), size = 4) 

# hclust
set.seed(1)
product_list <- sales_data_clean[, sample(unique(product_id), size = 100)]
sales_num <- sales_data_clean[product_id %in% product_list, 
                              .N, 
                              by = .(si_contact_id, product_id)] %>% 
    # .[product_id %in% c(10997L, 11419L, 15813L, 132852L, 136937L)] %>% 
    dcast(si_contact_id ~ product_id, value.var = "N") %>% 
    .[, lapply(.SD, function(x) ifelse(is.na(x), 0, x))] %>% 
    .[, si_contact_id := NULL] %>% 
    as.matrix()

plot(hclust(dist(scale(sales_num)), method = "average"), 
     main = "...",
     xlab = "", sub = "")

dd <- as.dist(1 - cor(t(scale(sales_num))))
plot(hclust(dd, method = "average"), 
     main = "...",
     xlab = "", sub = "")
