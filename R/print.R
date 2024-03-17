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
format.pairrel = function(x, cap = TRUE, simplify = FALSE,
                          includePaths = !simplify, ...) {

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
  if(cap)
    s = capit(s)

  names(paths) = s

  # Collect and print
  if(includePaths)
    s = unlist(lapply(s, function(r) c(r, paste("  ", paths[[r]]))))

  s
}
