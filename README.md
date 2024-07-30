
<!-- README.md is generated from README.Rmd. Please edit that file -->

# verbalisr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/verbalisr)](https://CRAN.R-project.org/package=verbalisr)
[![](https://cranlogs.r-pkg.org/badges/grand-total/verbalisr?color=yellow)](https://cran.r-project.org/package=verbalisr)
[![](https://cranlogs.r-pkg.org/badges/last-month/verbalisr?color=yellow)](https://cran.r-project.org/package=verbalisr)
<!-- badges: end -->

The purpose of **verbalisr** is to describe pedigree relationships in
plain language. This is often helpful in order to understand complex
genealogies. Given two members of any pedigree, **verbalisr** spells out
the connecting paths between them, using common terminology like
*great-grandmother* and *half first cousins*.

To see **verbalisr** in action, check out the interactive app
**QuickPed** for building and analysing pedigrees, available online
here: <https://magnusdv.shinyapps.io/quickped>.

The algorithm behind **verbalisr** is described in detail in this paper:
[QuickPed: an online tool for drawing pedigrees and analysing
relatedness](https://doi.org/10.1186/s12859-022-04759-y) (Vigeland, BMC
Bioinformatics, 2022).

The **verbalisr** package is part of the
[pedsuite](https://magnusdv.github.io/pedsuite/) framework for pedigree
analysis in R.

## Installation

To get the current official version of **verbalisr**, install from CRAN
as follows:

``` r
install.packages("verbalisr")
```

Alternatively, the development version can be installed from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("magnusdv/verbalisr")
```

## Example

``` r
library(verbalisr)
#> Loading required package: pedtools
```

Here is an example involving a double-cousin-like relationship:

``` r
x = doubleCousins(degree1 = 1, removal1 = 1, half1 = TRUE,  # half first cousins once removed
                  degree2 = 2, removal2 = 0)                # second cousins

plot(x, hatched = leaves(x))
```

<img src="man/figures/README-dblcous-1.png" width="65%" style="display: block; margin: auto;" />

We apply `verbalise()` to describe the relationship between the
children:

``` r
verbalise(x, ids = 16:17)
#> Half first cousins once removed
#>    16-10-[4]-12-15-17
#> Second cousins
#>    16-13-6-[1,2]-8-14-17
```

This output shows that 16 and 17 are simultaneous first cousins once
removed and second cousins. Below each description follows the
corresponding path, with its top-most shared ancestor(s) indicated in
brackets. The first path has one ancestor on top, `[4]`, indicating a
*half* relationship, while the second has two ancestors on top, `[1,2]`,
contributing a *full* relationship.

## A bigger example: The royal Habsburg family

The figure below shows a subset of the (infamously inbred) royal
Habsburg family, contained in the built-in dataset `habsburg`.
Untangling all the loops in this pedigree *by hand* would be a daunting
task, making it a good test case for **verbalisr**.

``` r
plot(habsburg, hatched = "Charles II", cex = 0.6)
```

<img src="man/figures/README-habsburg-1.png" width="85%" style="display: block; margin: auto;" />

The inbreeding coefficient of King Charles II of Spain (the bottom
individual) has been estimated to be around 25%, i.e., similar to a
child produced by brother-sister incest. We can validate this with the
**ribd** package, which provides the function `inbreeding()`:

``` r
ribd::inbreeding(habsburg, "Charles II")
#> [1] 0.230957
```

(The answer is a bit less than 25% since we are only looking at a subset
of the historic family tree.)

The high inbreeding coefficient shows that the parents of Charles II
were closely related. But *how* were they related? **verbalisr** gives
the answer:

``` r
rel = verbalise(habsburg, ids = c("Philip IV", "Mariana"))
rel
#> Avuncular: Philip IV is an uncle of Mariana
#>    Philip IV-[Philip III,Margarita]-Maria Anna (3)-Mariana
#> First cousins once removed
#>    Philip IV-Margarita-[Charles II of A,Maria Anna]-Ferdinand II-Ferdinand III-Mariana
#> Second cousins once removed
#>    Philip IV-Margarita-Maria Anna-[Albert V,Anna (2)]-William V-Maria Anna (2)-Ferdinand III-Mariana
#> Triple second cousins twice removed
#>    Philip IV-Margarita-Charles II of A-[Ferdinand I,Anna]-Maximillian II-Anna (3)-Philip III-Maria Anna (3)-Mariana
#>    Philip IV-Margarita-Charles II of A-[Ferdinand I,Anna]-Anna (2)-Maria Anna-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Margarita-Charles II of A-[Ferdinand I,Anna]-Anna (2)-William V-Maria Anna (2)-Ferdinand III-Mariana
#> Triple third cousins
#>    Philip IV-Philip III-Anna (3)-Maximillian II-[Ferdinand I,Anna]-Charles II of A-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Anna (3)-Maximillian II-[Ferdinand I,Anna]-Charles II of A-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Margarita-Maria Anna-Anna (2)-[Ferdinand I,Anna]-Charles II of A-Ferdinand II-Ferdinand III-Mariana
#> Septuple third cousins once removed
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Ferdinand I-Charles II of A-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Ferdinand I-Charles II of A-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Margarita-Charles II of A-Ferdinand I-[Philip I,Joanna]-Charles V-Philip II-Philip III-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Anna (3)-Maximillian II-[Ferdinand I,Anna]-Anna (2)-Maria Anna-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Anna (3)-Maximillian II-[Ferdinand I,Anna]-Anna (2)-Maria Anna-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Philip III-Anna (3)-Maximillian II-[Ferdinand I,Anna]-Anna (2)-William V-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Margarita-Maria Anna-Anna (2)-[Ferdinand I,Anna]-Maximillian II-Anna (3)-Philip III-Maria Anna (3)-Mariana
#> Sextuple third cousins twice removed
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-Maria Anna-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-Maria Anna-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-William V-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Philip III-Philip II-Charles V-[Philip I,Joanna]-Isabella (2)-Christina-Renata-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Margarita-Charles II of A-Ferdinand I-[Philip I,Joanna]-Charles V-Maria-Anna (3)-Philip III-Maria Anna (3)-Mariana
#>    Philip IV-Margarita-Charles II of A-Ferdinand I-[Philip I,Joanna]-Isabella (2)-Christina-Renata-Maria Anna (2)-Ferdinand III-Mariana
#> Triple 4'th cousins
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Ferdinand I-Charles II of A-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Ferdinand I-Charles II of A-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Margarita-Maria Anna-Anna (2)-Ferdinand I-[Philip I,Joanna]-Charles V-Philip II-Philip III-Maria Anna (3)-Mariana
#> Septuple 4'th cousins once removed
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-Maria Anna-Margarita-Maria Anna (3)-Mariana
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-Maria Anna-Ferdinand II-Ferdinand III-Mariana
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Ferdinand I-Anna (2)-William V-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Philip III-Anna (3)-Maria-Charles V-[Philip I,Joanna]-Isabella (2)-Christina-Renata-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Philip III-Anna (3)-Maximillian II-Ferdinand I-[Philip I,Joanna]-Isabella (2)-Christina-Renata-Maria Anna (2)-Ferdinand III-Mariana
#>    Philip IV-Margarita-Maria Anna-Anna (2)-Ferdinand I-[Philip I,Joanna]-Charles V-Maria-Anna (3)-Philip III-Maria Anna (3)-Mariana
#>    Philip IV-Margarita-Maria Anna-Anna (2)-Ferdinand I-[Philip I,Joanna]-Isabella (2)-Christina-Renata-Maria Anna (2)-Ferdinand III-Mariana
```

## Controlling the output

The output of `verbalise()` is actually a detailed list containing
various data about each pedigree path. When the output is printed to the
screen, however, a special `print` method is called, which formats the
data into reader-friendly statements.

The print method accepts various arguments for controlling the output,
including `simplify`, `abbreviate`, `includePaths` and `cap`. For
example, setting `cap` to FALSE results in all-lowercase output, instead
of the default first-letter capitalisation. If `simplify` is TRUE, a
simplified description is printed. By default, this also removes the
path details, but this may be overridden by the `includePaths` argument.

Here is a simplified description of Charles II’s parents:

``` r
print(rel, simplify = TRUE)
#> Uncle-niece
#> First cousins once removed
#> Second cousins once removed
#> Triple second cousins twice removed
#> Triple third cousins
#> Septuple third cousins once removed
#> Sextuple third cousins twice removed
#> Triple 4'th cousins
#> Septuple 4'th cousins once removed
```

Even shorter descriptions are obtained by applying standard
abbreviations. This leaves the most important words (such as `cousins`)
intact, but shortens quantifiers like `once removed` into `1r`.

``` r
print(rel, simplify = TRUE, abbreviate = TRUE)
#> Uncle-niece
#> 1st cousins 1r
#> 2nd cousins 1r
#> Triple 2nd cousins 2r
#> Triple 3rd cousins
#> Sept 3rd cousins 1r
#> Sext 3rd cousins 2r
#> Triple 4th cousins
#> Sept 4th cousins 1r
```

Finally, if you want the output as a character vector instead of just
the printout, replace `print()` with `format()`:

``` r
format(rel, simplify = TRUE, abbreviate = TRUE)
#> [1] "Uncle-niece"           "1st cousins 1r"        "2nd cousins 1r"        "Triple 2nd cousins 2r"
#> [5] "Triple 3rd cousins"    "Sept 3rd cousins 1r"   "Sext 3rd cousins 2r"   "Triple 4th cousins"   
#> [9] "Sept 4th cousins 1r"
```
