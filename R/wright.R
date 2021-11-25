wright = function(x) {
  stopifnot(inherits(x, "pairrel"))

  s = 0
  for(p in x) {
    expo = sum(p$nSteps) + 1
    f = p$ancInb
    s = s + 0.5^expo * (length(f) + sum(f)) # ok regardless of half/full
  }

  s
}


validateKinship = function(x, ids) {
  v = verbalise(x, ids, verbose = FALSE)
  if(!all.equal(wright(v), kinship(x, ids))) stop("err")
}
