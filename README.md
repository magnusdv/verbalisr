
<!-- README.md is generated from README.Rmd. Please edit that file -->

# verbalisr

<!-- badges: start -->
<!-- badges: end -->

The purpose of **verbalisr** is to describe pedigree relationships in
plain language. This is often helpful in order to understand complex
genealogies. Given two members of any pedigree, **verbalisr** spells out
the connecting paths between them, using common terminology like
*great-grandmother* and *half first cousins*.

**verbalisr** is part of the **ped suite** framework for pedigree
analysis in R.

## Installation

The development version of **verbalisr** can be installed from
[GitHub](https://github.com/) with:

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
x = doubleCousins(degree1 = 1, removal1 = 1,
                  degree2 = 2, removal2 = 0)

plot(x, hatched = 15:16)
```

<img src="man/figures/README-dblcous-1.png" width="60%" />

To get a written description of the two youngest members, we use
`verbalise()`:

``` r
verbalise(x, ids = 15:16)
#> first cousins once removed (common ancestors: 3, 4)
#> second cousins (common ancestors: 1, 2)
```
