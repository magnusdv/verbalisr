# verbalisr 0.6.0

* Simplified descriptions of lineal and avuncular relationships are now available through the argument `simplify` of `format.pairrel()`. Example: `linearPed(2) |> verbalise(c(1,5)) |> print(simplify = T)`.

* `verbalise()` now behaves better when the input is a list of pedigrees.

* Reorganise and improve docs; update README.

* Fix typo "newphew" -> "nephew".

* Add rhub v2 GitHub Actions workflow.


# verbalisr 0.5.2

* Minor code updates; no user-visible changes


# verbalisr 0.5.1

* Fix CRAN complaint regarding package doc.

* Added CITATION file.

* Require **pedtools** 2.2.0 and **ribd** 1.5.0


# verbalisr 0.5.0

This is a maintenance release with only minor changes.

* Tweak the description of double asymmetric relationships.

* In README, link to QuickPed paper describing the **verbalisr** algorithm.


# verbalisr 0.4.0

* This version requires **pedtools** 1.1.0 and **ribd** 1.3.1.

* The pedigree paths are now sorted more sensibly than before.

* New dataset `habsburg` showing the royal Habsburg family.

* The `format()` gains logical parameters `cap` (first letter capitalisation) and `includePaths`, both defaulting to TRUE.

* The `verbose` argument of `verbalise()` should never have been there, and has been dropped.


# verbalisr 0.3.0

* Add separate `print()` and `format()` methods.

* The main code of `verbalise()` has been overhauled.


# verbalisr 0.2.1

* Initial CRAN version
