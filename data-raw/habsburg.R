## code to prepare `habsburg` dataset goes here

library(pedtools)

# Alternative version of pedtools::readPed() TODO: fix there
# Deals with names with spaces!
readPed2 = function(pedfile) {
  cls = c("id", "fid", "mid", "sex")

  df = read.table(pedfile, sep = "\t", header = TRUE, colClasses = "character",
                  check.names = FALSE, quote = "\"", encoding = "UTF-8")
  names(df) = nms = tolower(names(df))

  # Convert to ped object
  as.ped(df[cls])
}

habsburg = readPed2("data-raw/habsburg.ped")

usethis::use_data(habsburg, overwrite = TRUE)
