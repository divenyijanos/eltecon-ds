# load neccessary pkgs ----
library(data.table)
library(magrittr)
library(ggplot2)

# read-in the prepared dataset ----
astra_h_whole_listings <- fread(
  "week 3-4/data/astra_h_ads_20190912_cleaned.csv",
  encoding = "UTF-8"
)

# inspect data ----
View(head(astra_h_whole_listings))
names(astra_h_whole_listings)

astra_h <- astra_h_whole_listings[,
    .(`Hirdetéskod`, `Vételár`, `Szín`, `Állapot`, `Évjárat`,
      `Kilométeróra állása`, `Üzemanyag`, `Teljesítmény`, `Kivitel`)
]

astra_h[, .(
    `Hirdetések száma`    = .N,
    `Medián Vételár`      = median(`Vételár`),
    `Medián KM`           = median(`Kilométeróra állása`),
    `Medián Teljesítmény` = median(`Teljesítmény`)
)]


# - geom_col / geom_histogram
ggplot(astra_h, aes(x = Vételár)) +
  geom_histogram()
  
# - scatterplot (y vs x)
ggplot(
  astra_h[Kivitel %in% c("Ferdehátú", "Kombi")], 
  aes(y = Vételár, x = `Kilométeróra állása`)
) +
  geom_point(aes(color = Kivitel)) +
  geom_smooth(method = "lm") +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "kocsik",
    subtitle = "alcim",
    caption = "blabla",
    x = "KM"
  ) +
  facet_grid(Kivitel~`Évjárat`) +
  theme_minimal()

# Number of listings per year
astra_h %>%
    .[, .N, by = `Évjárat`] %>%
    ggplot(aes(x = `Évjárat`, y = N)) +
        geom_col() +
        labs(
            title = "Number of listings by year",
            y = "Number of listings"
        )

# or simply using geom_histogram (no need to pre-aggregate)
ggplot(astra_h, aes(`Vételár`)) +
    geom_histogram(bins = 10) +
    labs(
        title = "Number of listings by KMs driven",
        y = "Number of listings"
    )

# price vs KMs driven
ggplot(astra_h, aes(x = `Kilométeróra állása`, y = `Vételár`)) +
    geom_point() +
    labs(title = "Price vs KMs driven") +
    scale_x_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal()

# price vs year
ggplot(astra_h, aes(x = as.factor(`Évjárat`), y = `Vételár`)) +
    geom_boxplot() +
    labs(
        title = "Price vs Year",
        x = "Évjárat"
    ) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal()

# or a more "manager-friendly" version
astra_h[,
    .(min = min(`Vételár`), max = max(`Vételár`), median = median(`Vételár`), N = .N),
    by = `Évjárat`
] %>%
    ggplot(aes(x = as.factor(`Évjárat`), y = median, ymin = min, ymax = max)) +
        geom_pointrange() +
        geom_text(aes(label = paste("n =", N)), vjust = -0.5, size = 3.25) +
        labs(
            title = "Vételárak megoszlása az évjárat tekintetében",
            x = "Évjárat", y = "Vételár",
            caption = "A hasznaltauto.hu-n elérhető adatok alapján"
        ) +
        scale_y_continuous(labels = scales::comma) +
        coord_flip() +
        theme_minimal()

# adding one more dimension ----
p <- ggplot(astra_h, aes(x = `Kilométeróra állása`, y = `Vételár`)) +
    geom_point(aes(color = as.factor(`Évjárat`))) +
    labs(title = "Price vs KMs driven") +
    scale_x_continuous(labels = scales::comma) +
    scale_y_continuous(labels = scales::comma) +
    theme_minimal()

# extending a plot object!
p2 <- p + facet_grid(~`Évjárat`) +
    theme(
        legend.position = "none",
        axis.text.x = element_text(angle = 45)
    )

# "prediction" with ggplot!
p2 + geom_smooth(method = "lm")


# Re-usable plotting w/ functions ----
plotNumListingPerGrp <- function(listings, grp) {
    listings[, .(num_listing = .N), by = grp] %>%
        ggplot(aes_string(x = grp, y = "num_listing")) +
        geom_col() +
        labs(
            title = paste("Hirdetések száma,", grp, "szerint"),
            y = "Hirdetések száma"
        ) +
        theme_minimal()
}

plotNumListingPerGrp(astra_h, "Évjárat")
plotNumListingPerGrp(astra_h, "Kivitel")
plotNumListingPerGrp(astra_h, "Üzemanyag")
