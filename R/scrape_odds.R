
# Load packages -----------------------------------------------------------

library(dplyr)    # CRAN v1.0.5
library(magrittr) # CRAN v2.0.1
library(rvest)    # CRAN v1.0.0


# Scrape odds from NordicBet ----------------------------------------------

ldf <- list()

nordicbet_html <- read_html("https://www.nordicbet.dk/betting/politik-og-finans/danmark/dansk-politik?tab=outrights")

for (i in c(".obg-selection-content-label", ".obg-numeric-change span")) {
  ldf[[i]] <- nordicbet_html %>%
    html_nodes(i) %>%
    html_text()
}

df_nordicbets <- as.data.frame(do.call("cbind", ldf)) %>%
  rename(pm = ".obg-selection-content-label",
         odds = ".obg-numeric-change span") %>%
  mutate(bettingfirm = "NordicBet",
         timestamp = as.character(Sys.time()),
         odds = as.numeric(odds))


# Write data to CSV -------------------------------------------------------

df <- read.csv("data-odds/odds_data.csv") %>%
  bind_rows(df_nordicbets)

write.csv(df, "data-odds/odds_data.csv", row.names = FALSE)

