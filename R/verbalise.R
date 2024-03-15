#' Describe a pairwise relationship
#'
#' The description includes all pedigree paths between the two individuals,
#' indicating with brackets the topmost common ancestors in each path.
#'
#' @param x A `ped` object, or a list of such.
#' @param ids A vector containing the names of two pedigree members.
#'
#' @return An object of class `pairrel`. This is essentially a list of lists,
#'   where each inner list describes a single path.
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
#' verbalise(y)
#'
#' # Example 3: Full sib mating
#'
#' z = fullSibMating(1)
#' verbalise(z)
#' verbalise(z, ids = c(1,5))
#'
#' # Example 4: Quad half first cousins
#'
#' w = quadHalfFirstCousins()
#' verbalise(w)
#'
#' @importFrom ribd kinship
#' @export
verbalise = function(x, ids = leaves(x)) {
  ids = as.character(ids)
  checkIds(x, ids, exactly = 2)

  if(is.pedList(x)) {
    cmps = getComponent(x, ids, checkUnique = FALSE, errorIfUnknown = TRUE)

    # If from different components: Unrelated
    if(cmps[1] != cmps[2])
      return(unrelatedPair(x, ids))

    # Otherwise: zoom in to component
    x = x[[cmps[1]]]
  }

  ### By now, connected ped

  kinmat = kinship(x)
  phi = kinmat[ids[1], ids[2]]
  inb = 2 * diag(kinmat) - 1

  # If unrelated: Return early
  if(phi == 0)
    return(unrelatedPair(x, ids))

  id1 = ids[1]; id2 = ids[2]
  SEX = getSex(x, named = TRUE)

  # Vector of all common ancestors
  comAnc = commonAncestors(x, ids, inclusive = TRUE)

  # List of lists: All paths from each common ancestor
  descPth = descentPaths(x, comAnc)

  # Split into paths to each id
  allpaths = lapply(descPth, function(plist) {
    p1 = lapply(plist, function(p) p[seq_len(match(id1, p, nomatch = 0))])
    p2 = lapply(plist, function(p) p[seq_len(match(id2, p, nomatch = 0))])
    list(unique.default(removeEmpty(p1)),
         unique.default(removeEmpty(p2)))
  })

  PATHS = list()
  taken = character()

  for(a in comAnc) {
    a.to.id1 = allpaths[[a]][[1]]
    a.to.id2 = allpaths[[a]][[2]]

    for(p1 in a.to.id1) {
      for(p2 in a.to.id2) {

        # If intersection: Ignore
        if(length(intersect(p1[-1], p2[-1])))
          next

        pd = pathData(x, p1, p2, inb = inb)
        if(pd$path %in% taken)
          next

        PATHS = c(PATHS, list(pd))
        taken = c(taken, pd$path)
      }
    }
  }

  # Sort
  PATHS = PATHS[order(sapply(PATHS, function(p) p$degree),
                      sapply(PATHS, function(p) sum(p$nSteps)),
                      sapply(PATHS, function(p) -p$removal))]

  structure(PATHS, class = "pairrel")
}

