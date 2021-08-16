# Preferred version of stop()
stop2 = function(...) {
  a = lapply(list(...), toString)
  a = append(a, list(call. = FALSE))
  do.call(stop, a)
}

removeEmpty = function(x) {
  x[lengths(x) > 0]
}

ordinal = function(n) {
  if(n < 0) stop2("`n` must be nonnegative")
  switch(min(n, 4), "first", "second", "third", paste0(n, "'th"))
}

numtimes = function(n) {
  if(n < 0) stop2("`n` must be nonnegative")
  if(n == 0) return("")
  if(n == 1) return("once")
  if(n == 2) return("twice")
  paste(n, "times")
}

tuple = function(n) {
  if(n < 1) stop2("`n` must be positive")
  if(n > 8) return(paste(n, "times"))
  switch(n, "single", "double", "triple", "quadruple", "quintuple", "sextuple", "septuple", "octuple")
}

indent = function(x, level = 0, capit = as.logical(level == 0)) {
  if(capit)
    x[1] = capit(x[1])

  paste0(strrep(" ", level), x)
}

# Replace duplications by prefixing "double" etc
#' @importFrom stats setNames
doublify = function(x, n = NULL) {
  if(is.null(n))
    tab = as.list(table(x))
  else
    tab = setNames(as.list(n), x)

  y = lapply(names(tab), function(s) {
    tup = tab[[s]]
    if(tup > 1)
      paste(tuple(tup), s)
    else s
  })

  unlist(y)
}


capit = function(x) {
  substr(x, 1, 1) = toupper(substr(x, 1, 1))
  x
}
