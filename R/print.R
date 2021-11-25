#' @export
format.pairrel = function(x, ...) {

  if(length(x) == 1 && x[[1]]$type == "unrelated")
    return("Unrelated")

  # Descriptions: Relationship + details
  descrips = vapply(x, FUN.VALUE = "", function(p)
    if(is.null(p$details)) p$rel else paste0(p$rel, ": ", p$details))

  # Add paths
  uniq = unique.default(descrips)
  paths = lapply(uniq, function(dsc)
    sapply(x[descrips == dsc], function(p) p$path))
  names(paths) = doublify(uniq, n = lengths(paths))

  # Collect and print
  completeText(paths)
}

#' @export
print.pairrel = function(x, ...) {
  txt = format(x)
  cat(txt, sep = "\n")
  invisible(x)
}
