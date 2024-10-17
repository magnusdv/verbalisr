
vrb = function(x, ids = leaves(x), paths = FALSE, ...) {
  format(verbalise(x, ids), includePaths = paths, ...)
}

vrbSimpl = function(x, ids = leaves(x)) {
  vrb(x, ids, simplify = TRUE, cap = FALSE)
}

vrbAbbr = function(x, ids = leaves(x)) {
  vrb(x, ids, abbreviate = TRUE, simplify = TRUE, cap = FALSE)
}

# Test cases
x = nuclearPed(2, sex = 1:2)
y = cousinPed(3, symmetric = TRUE)
z = cousinPed(3, half = TRUE, symmetric = TRUE)
# plot(list(x,y,z))


test_that("verbalise() describes basic relationships", {
  expect_equal(vrb(x), "Full siblings")
  expect_equal(vrb(x, ids = 1:2), "Unrelated")
  expect_equal(vrb(x, ids = 2:3), "Lineal of degree 1: 2 is the mother of 3")

  expect_equal(vrb(y, c(1, 8)), "Lineal of degree 2: 1 is a grandfather of 8")
  expect_equal(vrb(y, c(1, 12)), "Lineal of degree 3: 1 is a great-grandfather of 12")

  expect_equal(vrb(y, c(4,9)), "Avuncular: 4 is an aunt of 9")
  expect_equal(vrb(y, c(5,8)), "Avuncular: 5 is an uncle of 8")
  expect_equal(vrb(y, c(4,13)), "Grand-avuncular: 4 is a grandaunt of 13")
  expect_equal(vrb(y, c(5,12)), "Grand-avuncular: 5 is a granduncle of 12")
})

test_that("verbalise() describes cousin relationships", {
  expect_equal(vrb(y, c(8,9)), "First cousins")
  expect_equal(vrb(y, c(8,13)), "First cousins once removed")
  expect_equal(vrb(y, c(8,16)), "First cousins twice removed")
  expect_equal(vrb(y, c(15,9)), "First cousins twice removed")

  expect_equal(vrb(y, c(12,13)), "Second cousins")
  expect_equal(vrb(y, c(12,16)), "Second cousins once removed")
  expect_equal(vrb(y, c(15,16)), "Third cousins")
})

test_that("verbalise() describes half relationships", {
  expect_equal(vrb(z, c(5,6)), "Half siblings")
  expect_equal(vrb(z, c(5,10)), "Half-avuncular: 5 is a half-aunt of 10")
  expect_equal(vrb(z, c(6,9)), "Half-avuncular: 6 is a half-uncle of 9")
  expect_equal(vrb(z, c(5,14)), "Half-grand-avuncular: 5 is a half-grandaunt of 14")
  expect_equal(vrb(z, c(6,13)), "Half-grand-avuncular: 6 is a half-granduncle of 13")
  expect_equal(vrb(z, c(5,17)), "Half-great-grand-avuncular: 5 is a half-great-grandaunt of 17")

  expect_equal(vrb(z, c(9,10)), "Half first cousins")
  expect_equal(vrb(z, c(9,14)), "Half first cousins once removed")
  expect_equal(vrb(z, c(10,16)), "Half first cousins twice removed")

  expect_equal(vrb(z, c(13,14)), "Half second cousins")
  expect_equal(vrb(z, c(13,17)), "Half second cousins once removed")
  expect_equal(vrb(z, c(17,16)), "Half third cousins")
})

test_that("simplification and non-capitalisation work", {
  expect_equal(vrbSimpl(x), "full siblings")
  expect_equal(vrbSimpl(x, c(1,3)), "father-son")
  expect_equal(vrbSimpl(x, c(1,4)), "father-daughter")
  expect_equal(vrbSimpl(x, 2:3), "mother-son")
  expect_equal(vrbSimpl(x, c(2,4)), "mother-daughter")

  expect_equal(vrbSimpl(y, c(1,8)), "grandfather-granddaughter")
  expect_equal(vrbSimpl(y, c(1,9)), "grandfather-grandson")
  expect_equal(vrbSimpl(y, c(2,8)), "grandmother-granddaughter")
  expect_equal(vrbSimpl(y, c(2,9)), "grandmother-grandson")

  expect_equal(vrbSimpl(y, c(4,9)), "aunt-nephew")
  expect_equal(vrbSimpl(y, c(5,8)), "uncle-niece")
  expect_equal(vrbSimpl(y, c(8,9)), "first cousins")

  expect_equal(vrbSimpl(z, c(5,10)), "half-aunt--half-nephew")
  expect_equal(vrbSimpl(z, c(6,9)), "half-uncle--half-niece")
  expect_equal(vrbSimpl(z, c(9,10)), "half first cousins")
})

test_that("abbrevation works", {
  expect_equal(vrbAbbr(x), "full siblings")
  expect_equal(vrbAbbr(x, c(1,3)), "father-son")

  expect_equal(vrbAbbr(y, c(1,13)), "g-grandfather--g-grandson")
  expect_equal(vrbAbbr(y, c(1,16)), "gg-grandfather--gg-grandson")
  expect_equal(vrbAbbr(y, c(12:13)), "2nd cousins")
  expect_equal(vrbAbbr(y, c(15:16)), "3rd cousins")

  expect_equal(vrbAbbr(z, c(5,17)), "half-g-grandaunt--half-g-grandnephew")
  expect_equal(vrbAbbr(z, c(13:14)), "half 2nd cousins")
  expect_equal(vrbAbbr(z, c(16:17)), "half 3rd cousins")
})

test_that("collapsing works", {
  expect_equal(vrb(doubleCousins(1,2), collapse = " + "), "First cousins + second cousins")
  expect_equal(vrb(doubleCousins(1,2), collapse = " + ", abbr = T), "1st cousins + 2nd cousins")
  expect_equal(vrb(doubleCousins(4,1), collapse = " *** ", abbr = T), "1st cousins *** 4th cousins")
  expect_equal(vrb(doubleCousins(1,2, half1 = TRUE), collapse = " + "), "Half first cousins + second cousins")

  expect_equal(vrb(fullSibMating(2), collapse = " / ", abbr = T, cap = F),
               "full siblings / dbl 1st cousins / quad 2nd cousins")
})
