#' @importFrom ribd inbreeding
pathData = function(x, p1, p2, inb = NULL) {
  p1 = as.character(p1)
  p2 = as.character(p2)
  if(p1[1] != p2[1])
    stop2("Both paths must start at the common ancestor")
  anc = as.character(p1[1])

  # The two connected indivs
  leaves = c(p1[length(p1)], p2[length(p2)]) # do this here to avoid empty paths

  # Remove ancestor from paths
  v1 = p1[-1]
  v2 = p2[-1]

  l1 = length(v1)
  l2 = length(v2)

  # Path type
  type = if(l1 == 0 || l2 == 0)
    "lineal"
  else if(l1 == 1 && l2 == 1)
    "sibling"
  else if(l1 == 1 || l2 == 1)
    "avuncular"
  else
    "cousin"

  # Full or half?
  if(type == "lineal")
    full = NA
  else {
    pars1 = parents(x, v1[1]) # = character(0) if empty
    pars2 = parents(x, v2[1])
    full = setequal(pars1, pars2)
    if(full)
      anc = pars1
  }
  half = isFALSE(full) # for use below; not reported

  # Degree/removal
  nSteps = c(l1, l2)
  degree = sum(nSteps) - as.integer(isTRUE(full)) # NB: not cousin degree
  removal = abs(diff(nSteps))

  # Number of great/grand (lineal & avuncular only)
  ng = if(removal > 1) removal - 1 else 0

  # Inbreeding of ancs
  if(is.null(inb))
    inb = ribd::inbreeding(x)
  ancInb = inb[anc]

  # Sexes along path from A to B (not inclusive). Include anc only for half rels.
  pth = c(rev(v1[-l1]), if(half) anc, v2[-l2])
  sex = getSex(x, named = TRUE)
  sexPath = paste0(c("p", "m")[sex[pth]], collapse = "")

  # top/bottom within leaves (used in lineal & avunc details below)
  top = if(l1 < l2) leaves[1] else leaves[2]
  bottom = setdiff(leaves, top)

  details = details2 = NULL
  # Relationship descriptions
  switch(type,
         lineal = {
           code = paste0("lin", degree)
           rel = paste("lineal of degree", degree)

           # details
           topDetail = switch(sex[top]+1, "parent", "father", "mother")
           botDetail = switch(sex[bottom]+1, "child", "son", "daughter")
           if(ng > 0) {
             greats = paste0(strrep("great-", ng - 1), "grand")
             topDetail = paste0(greats, topDetail)
             botDetail = paste0(greats, botDetail)
           }
           determ = if(ng > 0) "a" else "the"
           details = sprintf("%s is %s %s of %s", top, determ, topDetail, bottom)
           details2 = paste(topDetail, botDetail, sep = if(ng > 1) "--" else "-")
         },
         sibling = {
           code = if(half) "hs" else "fs"
           rel = paste(if(half) "half" else "full", "siblings")
         },
         avuncular = {
           code = paste0(if(half) "h", if(ng > 0) "g", if(ng > 1) ng, "av")
           rel = paste0(if(half) "half-",
                        if(ng > 1) strrep("great-", ng - 1),
                        if(ng > 0) "grand-",
                        "avuncular")
           # details
           topDetail = switch(sex[top]+1, "uncle", "uncle", "aunt")
           botDetail = switch(sex[bottom]+1, "nephew", "newphew", "niece")
           if(ng > 0) {
             greats = paste0(strrep("great-", ng - 1), "grand")
             topDetail = paste0(greats, topDetail)
             botDetail = paste0(greats, botDetail)
           }
           if(half) {
             topDetail = paste0("half-", topDetail)
             botDetail = paste0("half-", botDetail)
           }
           determ = if(substr(topDetail, 1, 1) %in% c("a", "u")) "an" else "a"
           details = sprintf("%s is %s %s of %s", top, determ, topDetail, bottom)
           details2 = paste(topDetail, botDetail, sep = if(half || ng > 1) "--" else "-")
         },
         cousin = {
           cousDeg = min(l1, l2) - 1
           code = paste0(if(half) "h", "c", cousDeg, "r", removal)
           rel = paste(ordinal(cousDeg), "cousins")
           if(half) rel = paste("half", rel)
           if(removal > 0) rel = paste(rel, numtimes(removal), "removed")
         }
  )

  # Path string
  ancBrack = sprintf("[%s]", paste0(anc, collapse = ","))
  path = paste0(c(rev(v1), ancBrack, v2), collapse = "-")

  list(v1 = v1, v2 = v2, leaves = leaves, anc = anc, full = full,
       nSteps = nSteps, degree = degree, removal = removal, ancInb = ancInb,
       sex = sex, sexPath = sexPath, path = path, code = code, type = type,
       rel = rel, details = details, details2 = details2)
}

unrelatedPair = function(x, ids) {
  sex = getSex(x, ids = ids, named = TRUE)
  emptypath = list(v1 = ids[1], v2 = ids[2], leaves = ids, anc = character(0), full = NA,
                   nSteps = c(Inf, Inf), degree = Inf, removal = 0,
                   ancInb = 0, sex = sex, sexPath = "", path = "",
                   code = "un", type = "unrelated", rel = "unrelated",
                   details = NULL, details2 = NULL)
  structure(list(emptypath), class = "pairrel")
}
