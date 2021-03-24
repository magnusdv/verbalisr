#' Describe a pairwise relationship
#'
#' @param x A `ped` object.
#' @param ids A vector of length 2, containing the names of two pedigree members.
#' @param verbose A logical.
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
#' # Example 3: Full sib mating
#'
#' z = fullSibMating(1)
#' verbalise(z, 5:6)
#' verbalise(z, c(1,5))
#'
#' @importFrom ribd inbreeding kinship
#' @export
verbalise = function(x, ids, verbose = TRUE) {
  if(!is.ped(x))
    stop2("Input is not a connected ped objects")

  if(length(ids) != 2)
    stop2("Argument `ids` must have length 2")

  phi = ribd::kinship(x, ids)

  ### Type 1: Unrelated
  if(phi == 0) {
    rel = "unrelated"
    if(verbose) cat(rel, sep = "\n")
    return(invisible(rel))
  }

  f = ribd::inbreeding(x)

  id1 = ids[1]; id2 = ids[2]

  ### Type 2: Full siblings
  par = parents(x, id1)
  if(length(par) == 2 && setequal(par, parents(x, id2))) {

    # 2a: Parents unrelated
    if(ribd::kinship(x, par) == 0) {
      rel = "full siblings of unrelated parents"
      if(verbose) cat(rel, sep = "\n")
      return(invisible(rel))
    }

    # 2b: Parents related
    s = "full siblings, whose parents are:"
    parentRel = verbalise(x, par, verbose = FALSE)
    rel = c(s, paste0("  ", parentRel))
    if(verbose) cat(rel, sep = "\n")
    return(invisible(rel))
  }

  ancs1 = ancestors(x, id1)
  ancs2 = ancestors(x, id2)

  ### Type 3: Lineal relationship
  lineal = id1 %in% ancs2 || id2 %in% ancs1
  if(lineal) {
    top = if(id1 %in% ancs2) id1 else id2
    bot = if(top == id1) id2 else id1

    allpaths = pedtools:::.descentPaths(x, top)[[1]]
    paths = allpaths[vapply(allpaths, function(p) bot %in% p, FUN.VALUE = FALSE)]
    paths = unique.default(lapply(paths, function(p) p[2:match(bot, p)]))

    rel = lineal2text(x, top, bot, degrees = lengths(paths))
    if(verbose) cat(rel, sep = "\n")
    return(invisible(rel))
  }

  ### Type 4: General
  comAnc = commonAncestors(x, ids)

  paths = lapply(pedtools:::.descentPaths(x, comAnc), function(plist) {
    pp = lapply(plist, function(p) if(!any(ids %in% p)) NULL else p[2:max(which(p %in% ids))])
    unique.default(pp[lengths(pp) > 0])
  })
  names(paths) = comAnc

  REL = character(0)
  for(a in comAnc) {
    allp = paths[[a]]
    allp1 = allp[vapply(allp, function(p) p[length(p)] == ids[1], FALSE)]
    allp2 = allp[vapply(allp, function(p) p[length(p)] == ids[2], FALSE)]


    for(p1 in allp1) {   # message(paste(c(a, p1), collapse="-"))
      for(p2 in allp2) { # message("  ", paste(c(a, p2), collapse="-"))

        if(p1[1] == p2[1])
          next
        if(length(intersect(p1, p2)) > 0)
          next

        L1 = length(p1); L2 = length(p2)

        # 4a: Half sibs
        if(L1 == 1 && L2 == 1) {
          sex = switch(getSex(x, a), "paternal", "maternal")
          rel = paste(sex, "half siblings")
          REL = c(REL, rel)
          next
        }

        # Remaining types may be full of half
        full = setequal(parents(x, p1[1]), parents(x, p2[1]))
        if(full) {
          # id of spouse
          sps = setdiff(parents(x, p1[1]), a)
          paths[[sps]] = setdiff(paths[[sps]], list(p1, p2))
        }

        anc = if(full) c(a, sps) else a

        # 4b: Avuncular
        if(L1 == 1) {
          rel = avunc2text(x, id1, id2, degree = L2, anc = anc, full = full) #; print(rel)
          REL = c(REL, rel)
          next
        }
        if(L2 == 1) {
          rel = avunc2text(x, id2, id1, degree = L1, anc = anc, full = full)#; print(rel)
          REL = c(REL, rel)
          next
        }

        # 4c: Other
        rel = cousins2text(L1, L2, anc = anc)
        REL = c(REL, rel)
        next
      }
    }
  }

  REL = doublify(REL)

  if(verbose) cat(REL, sep = "\n")
  return(invisible(REL))
}

lineal2text = function(x, top, bottom, degrees) {
  degrees = sort(degrees)

  grand = sapply(degrees, function(d) {
    greats = if(d > 2) strrep("great-", d - 2) else ""
    if(d > 1) paste0(greats, "grand") else ""
  })

  topname = switch(getSex(x, top), "father", "mother")
  rel = paste0(grand, topname)
  rel = doublify(rel)

  determ = sapply(rel, function(r) if(r %in% c("mother", "father")) "the" else "a")

  s2 = sprintf("%s is %s %s of %s", top, determ, rel, bottom)

  if(length(degrees) == 1) {
    s = paste("direct descendence:", s2)
  }
  else {
    s = c("direct descendence, multiple lines:", paste0("  ", s2))
  }

  s
}

avunc2text = function(x, top, bottom, degree, anc = NULL, full) {
  if(degree < 2)
    stop2("avuncular relationship cannot have longest path length < 2")

  type = switch(getSex(x, top), "uncle", "aunt")

  if(degree == 2) {
    if(full)
      s = sprintf("avuncular (%s is an %s of %s)", top, type, bottom)
    else
      s = sprintf("half-avuncular (%s is a half-%s of %s)", top, type, bottom)
    return(s)
  }

  greats = strrep("great-", max(0, degree - 3))
  grand = paste0(greats, "grand")

  if(full)
    s = sprintf("%s-avuncular (%s is a %s%s of %s)", grand, top, grand, type, bottom)
  else
    s = sprintf("half %s-avuncular (%s is a half %s%s of %s)", grand, top, grand, type, bottom)

  s
}

cousins2text = function(deg1, deg2, anc) { #message(deg1, deg2, anc)
  # degs are path lengths; e.g. 1st cousins have deg1 = deg2 = 2.
  deg = min(deg1, deg2) - 1
  remov = abs(deg1 - deg2)

  s = paste(ordinal(deg), "cousins")

  if(remov > 0)
    s = paste(s, numtimes(remov), "removed")

  if(length(anc) == 1)
    s = sprintf("half %s (common ancestor: %s)", s, anc)
  else
    s = sprintf("%s (common ancestors: %s)", s, toString(anc))
  s
}
