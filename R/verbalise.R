#' Describe a pairwise relationship
#'
#' The description includes all pedigree paths between the two individuals,
#' indicating with brackets the topmost common ancestors in each path.
#'
#' @param x A `ped` object.
#' @param ids A vector containing the names of two pedigree members.
#' @param verbose A logical.
#' @param debug A logical, by default FALSE.
#'
#' @return A character vector.
#'
#' @examples
#'
#' # Example 1: Family quartet
#'
#' x = nuclearPed(2)
#' verbalise(x, 1:2)
#' verbalise(x, 2:3)
#' verbalise(x, 3:4)
#'
#' # Example 2: Complicated cousin pedigree
#'
#' y = doubleCousins(degree1 = 1, removal1 = 1, half1 = TRUE,
#'                   degree2 = 2, removal2 = 0, half2 = FALSE)
#' verbalise(y, leaves(y))
#'
#' # Example 3: Full sib mating
#'
#' z = fullSibMating(1)
#' verbalise(z, 5:6)
#' verbalise(z, c(1,5))
#'
#' # Example 4: Quad half first cousins
#'
#' w = quadHalfFirstCousins()
#' verbalise(w, leaves(w))
#'
#' @importFrom ribd inbreeding kinship
#' @export
verbalise = function(x, ids, verbose = interactive(), debug = FALSE) {
  if(length(ids) != 2)
    stop2("Argument `ids` must have length 2")
  if(ids[1] == ids[2])
    stop2("Duplicated ID label: ", ids[1])

  phi = ribd::kinship(x, ids)

  ### Unrelated
  if(phi == 0) {
    REL = "Unrelated"
    if(verbose) cat(REL, "\n")
    return(invisible(REL))
  }

  # By now, if ped list, ids are from the same comp!
  if(is.pedList(x))
    x = x[[getComponent(x, ids[1])]]

  id1 = ids[1]; id2 = ids[2]
  SEX = getSex(x, named = TRUE)

  # Vector of all common ancestors
  comAnc = commonAncestors(x, ids, inclusive = TRUE)

  # List of lists: All paths from each common ancestor
  descPth = pedtools:::.descentPaths(x, comAnc)
  names(descPth) = comAnc # TODO: fix i pedtools

  # Split into paths to each id
  allpaths = lapply(descPth, function(plist) {
    p1 = lapply(plist, function(p) p[seq_len(match(id1, p, nomatch = 0))])
    p2 = lapply(plist, function(p) p[seq_len(match(id2, p, nomatch = 0))])
    list(unique.default(removeEmpty(p1)),
         unique.default(removeEmpty(p2)))
  })

  PATHDATA = list()

  for(a in comAnc) {
    a.to.id1 = allpaths[[a]][[1]]
    a.to.id2 = allpaths[[a]][[2]]

    for(p1 in a.to.id1) {
      if(debug) message(paste(p1, collapse="-"))

      for(p2 in a.to.id2) {
        if(debug) message("  ", paste(p2, collapse="-"))

        # If intersection: Ignore
        if(length(intr <- intersect(p1[-1], p2[-1])) > 0) {
          if(debug) message("  (self-intersecting: ", toString(intr), ")")
          next
        }

        deg1 = length(p1) - 1
        deg2 = length(p2) - 1

        # Lineal relationships
        lineal = deg1 == 0 || deg2 == 0

        # Non-lineal rels may be full of half
        full = !lineal && setequal(parents(x, p1[2]), parents(x, p2[2]))

        # If full, remove corresponding path via spouse
        if(full) {
          spous = setdiff(parents(x, p1[2]), a)
          allpaths[[spous]][[1]] = setdiff(allpaths[[spous]][[1]], list(c(spous, p1[-1])))
          allpaths[[spous]][[2]] = setdiff(allpaths[[spous]][[2]], list(c(spous, p2[-1])))
        }

        # Shared ancestors
        anc = if(full) c(a, spous) else a

        # Type
        if(lineal) {
          type = "lineal"
          bottom = setdiff(ids, anc)
          descrip = lineal2text(anc, bottom, degree = deg1 + deg2, topsex = SEX[anc])
        }
        else if(deg1 == 1 && deg2 == 1) {
          type = "siblings"
          descrip = siblings2text(ids, full = full, parsex = SEX[anc])
        }
        else if(deg1 == 1 || deg2 == 1) {
          type = "avuncular"
          top = if(deg1 > deg2) id1 else id2
          bottom = setdiff(ids, top)
          descrip = avunc2text(top, bottom, degree = max(deg1, deg2), full = full, topsex = SEX[top])
        }
        else {
          type = "cousins"
          descrip = cousins2text(deg1, deg2, full = full)
        }

        # Complete path string
        ancBrack = sprintf("[%s]", paste0(anc, collapse = ","))
        pathStr = paste0(c(rev(p1[-1]), ancBrack, p2[-1]), collapse = "-")

        # Return relationship data
        dat = list(type = type, path1 = p1, path2 = p2,
                   deg = c(deg1, deg2), anc = anc, pathStr = pathStr, descrip = descrip)
        PATHDATA = c(PATHDATA, list(dat))
      }
    }
  }

  # Sort
  PATHDATA = PATHDATA[order(sapply(PATHDATA, function(dat) sum(dat$deg)))]

  # Doublify
  descrips = sapply(PATHDATA, function(dat) dat$descrip)
  uniqDesc = unique.default(descrips)
  summary = lapply(uniqDesc, function(dsc)
    sapply(PATHDATA[descrips == dsc], function(dat) dat$pathStr))
  names(summary) = doublify(uniqDesc, n = lengths(summary))

  # Parse
  REL = completeText(summary)
  if(verbose)
    cat(REL, sep = "\n")

  invisible(REL)
}



lineal2text = function(top, bottom, degree, topsex) {
  greats = if(degree > 2) strrep("great-", degree - 2) else ""
  grand  = if(degree > 1) paste0(greats, "grand") else ""
  determ = if(degree == 1) "the" else "a"

  topname = switch(topsex, "father", "mother")
  rel = paste0(grand, topname)

  sprintf("lineal of degree %d: %s is %s %s of %s", degree, top, determ, rel, bottom)
}

siblings2text = function(ids, full, parsex) {
  if(full) "full siblings"
  else sprintf("half siblings, %s", switch(parsex, "paternal", "maternal"))
}

avunc2text = function(top, bottom, degree, full, topsex) {
  type = switch(topsex, "uncle", "aunt")

  if(degree == 2) {
    if(full)
      s = sprintf("avuncular: %s is an %s of %s", top, type, bottom)
    else
      s = sprintf("half-avuncular: %s is a half-%s of %s", top, type, bottom)
    return(s)
  }

  greats = strrep("great-", max(0, degree - 3))
  grand = paste0(greats, "grand")

  if(full)
    s = sprintf("%s-avuncular: %s is a %s%s of %s", grand, top, grand, type, bottom)
  else
    s = sprintf("half %s-avuncular: %s is a half %s%s of %s", grand, top, grand, type, bottom)

  s
}


cousins2text = function(deg1, deg2, full) {
  deg = min(deg1, deg2) - 1
  remov = abs(deg1 - deg2)

  # Build string
  s = paste(ordinal(deg), "cousins")
  if(remov > 0)
    s = paste(s, numtimes(remov), "removed")
  if(!full)
    s = paste("half", s)
  s
}



completeText = function(x) {
  lines = lapply(names(x), function(s) {
    pths = x[[s]]
    c(paste("*", s), paste("   ", pths))
  })

  unlist(lines)
}

