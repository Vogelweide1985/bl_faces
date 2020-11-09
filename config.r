

library(rvest)
library(purrr)
library(aplpack)
library(lubridate)
config <- list()

config[["url"]] <- "https://de.wikipedia.org/wiki/Liste_der_Ministerpräsidenten_der_deutschen_Länder"
config[["url_bl"]] <- "https://de.wikipedia.org/wiki/Land_(Deutschland)"
