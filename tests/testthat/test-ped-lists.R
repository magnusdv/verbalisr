
vrb = function(...) format(verbalise(...))

test_that("verbalise() works in a simple ped list", {
  nuc = nuclearPed()
  x = list(nuc, singleton(4))
  expect_equal(vrb(x, 2:3), vrb(nuc, 2:3))
  expect_equal(vrb(x, 3:4), vrb(x, 1:2))

  expect_error(vrb(x, 5:6), "Unknown ID label")
  expect_error(vrb(x, 1:3), "Argument `ids` must have length 2")

})

test_that("verbalise() gives error in pedlist with duplicated labels", {
  x = list(nuclearPed(), singleton())
  expect_error(vrb(x, 1:2), "ID label is not unique: 1")

  # No error for unduplicated indivs
  expect_match(vrb(x, 2:3)[1], "2 is the mother of 3")
})
