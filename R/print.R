#' Format and print relationship descriptions
#'
#' This documents the options for formatting and printing the output of
#' [verbalise()].
#'
#' @param x An output of [verbalise()].
#' @param ... Arguments passed on to `format.pairrel()`.
#' @param cap A logical indicating if the first letter of each path description
#'   should be capitalised. By default TRUE.
#' @param simplify A logical. If TRUE, the descriptions of lineal and avuncular
#'   relationships are simplified. Default: FALSE.
#' @param abbreviate A logical. It TRUE, various abbreviations are applied to
#'   the descriptions, e.g. 'great-great-' -> 'gg-' and 'once removed' -> '1r'.
#'   Default: FALSE.
#' @param collapse A single string, or NULL. If given, and the relationship has
#'   multiple descriptions, these are concatenated with `paste(..., collapse =
#'   collapse)`.
#' @param includePaths A logical indicating if the complete paths should be
#'   included in the output. By default TRUE.
#'
#' @export
print.pairrel = function(x, ...) {
  txt = format(x, ...)
  cat(txt, sep = "\n")
  invisible(x)
}

#' @rdname print.pairrel
#' @export
format.pairrel = function(x, cap = TRUE, simplify = FALSE, abbreviate = FALSE,
                          collapse = NULL, includePaths = !simplify, ...) {

  if(length(x) == 1 && x[[1]]$type == "unrelated")
    return(if(cap) "Unrelated" else "unrelated")

  # Descriptions: Relationship + details
  descrips = vapply(x, FUN.VALUE = "", function(p) {
    if(simplify && !is.null(p$details2)) p$details2
    else if(is.null(p$details)) p$rel
    else paste0(p$rel, ": ", p$details)
  })

  # Collect path groups
  uniq = unique.default(descrips)
  paths = lapply(uniq, function(dsc)
    sapply(x[descrips == dsc], function(p) p$path))

  s = doublify(uniq, n = lengths(paths))

  if(abbreviate) {
    # Order is important!
    patts = c("great-" = "g", ggrand = "g-grand", #half = "h",
              double = "dbl", quadruple = "quad", quintuple = "quin", uple = "",
              once = "1", twice = "2", " times" = "", " removed" = "r",
              first = "1st", second = "2nd", third = "3rd", "'th" = "th")

    for(i in seq_along(patts))
      s = gsub(names(patts)[i], patts[i], s, fixed = TRUE)
  }

  if(!is.null(collapse) && length(s) > 1) {
    if(includePaths)
      stop2("Cannot collapse descriptions when `includePaths` is TRUE")
    s = paste(s, collapse = collapse)
  }

  if(cap)
    s = capit(s)

  # Collect and print
  if(includePaths) {
    names(paths) = s
    s = unlist(lapply(s, function(r) c(r, paste("  ", paths[[r]]))))
  }

  s
}
