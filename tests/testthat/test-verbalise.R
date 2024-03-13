
vrb = function(x, ids = leaves(x), cap = TRUE, includePaths = FALSE)
  format(verbalise(x, ids), cap = cap, includePaths = includePaths)

test_that("verbalise() describes basic relationships", {
  x = nuclearPed(2)
  expect_equal(vrb(x), "Full siblings")
  expect_equal(vrb(nuclearPed(2), ids = 1:2), "Unrelated")
  expect_equal(vrb(nuclearPed(2), ids = 2:3), "Lineal of degree 1: 2 is the mother of 3")

  expect_equal(vrb(halfSibPed()), "Half siblings")

  expect_match(vrb(linearPed(3), c(1, 7)), "Lineal of degree 3")

  expect_match(vrb(avuncularPed()), "Avuncular: 3 is an uncle of 6")

  expect_equal(vrb(cousinPed(1)), "First cousins")
  expect_equal(vrb(cousinPed(2)), "Second cousins")
  expect_equal(vrb(halfCousinPed(1)), "Half first cousins")
  expect_equal(vrb(halfCousinPed(2)), "Half second cousins")
})
