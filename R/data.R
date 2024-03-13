#' Habsburg pedigree.
#'
#' A subset of the royal Habsburg family, showing the ancestry of (the
#' infamously inbred) King Charles II of Spain.
#'
#' @format A `ped` object containing a pedigree with 29 members.
#'
#' @source Adapted from \url{https://en.wikipedia.org/wiki/Habsburg_family_tree}
#'
#' @examples
#'
#' plot(habsburg, hatched = "Charles II", cex = 0.7)
#'
#' verbalise(habsburg, ids = parents(habsburg, "Charles II"))
#'
"habsburg"
