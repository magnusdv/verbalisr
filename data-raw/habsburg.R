## code to prepare `habsburg` dataset goes here

library(pedtools)
habsburg = readPed("data-raw/habsburg.ped", colSep = "\t")
plot(habsburg)

usethis::use_data(habsburg, overwrite = TRUE)
