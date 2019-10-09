library(data.table)
library(magrittr)
library(ggplot2)
library(lubridate)

raw_dt <- fread("week 5-6/experiment_result.csv")
raw_dt

dt <- raw_dt[, 
       .(num_open = sum(did_open), num_send = .N), 
       by = group
] %>% 
    .[, .(group, open_rate = num_open / num_send)]

dt[group == "treatment", open_rate] / dt[group == "control", open_rate]

ggplot(dt, aes(x = group, y = open_rate)) + 
    geom_col() +
    labs(title = "Open rate for all period") + 
    ylab("Open rate")


raw_dt[, send_week := floor_date(as.Date(send_date), unit = "week")]

dt_week <- raw_dt[, 
       .(num_open = sum(did_open), num_send = .N), 
       by = .(group, send_week)
] %>% 
    .[, .(group, send_week, open_rate = num_open / num_send)]

effect_dt <- dcast(dt_week, send_week ~ group) %>% 
    .[, .(send_week, uplift = treatment / control)]

ggplot(effect_dt, aes(x = send_week, y = uplift)) + geom_line()


