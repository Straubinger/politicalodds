
# Load packages -----------------------------------------------------------

library(dplyr)
library(tidyr)
library(jsonlite)
library(httr)


# Odds from Danske Spil ---------------------------------------------------

danskespil_api <- GET("https://content.sb.danskespil.dk/content-service/api/v1/q/event-list?eventSortsIncluded=TNMT&includeChildMarkets=true&drilldownTagIds=20193")

danskespil_json <- danskespil_api |>
  content("text", encoding = "UTF-8") |>
  fromJSON(flatten = TRUE)

danskespil_data <- as.data.frame(danskespil_json$data$events) |>
  filter(name == "Statsminister efter næste folketingsvalg") |>
  unnest(markets, names_repair = "unique") |>
  unnest(outcomes, names_repair = "unique") |>
  unnest(prices, names_repair = "unique") |>
  select("spil" = name...5,
         "kandidat" = name...61,
         numerator,
         denominator,
         decimal) |>
  mutate(ts = Sys.time(),
         bookmaker = "Danske Spil")


# Write data to CSV -------------------------------------------------------

df <- read.csv("data-odds/odds_data.csv") |>
  mutate(ts = as.POSIXct(ts)) |>
  bind_rows(danskespil_data)

write.csv(df, "data-odds/odds_data.csv", row.names = FALSE)

