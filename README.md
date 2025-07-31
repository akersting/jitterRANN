# jitterRANN: Fast Nearest Neighbour Search with Random Tie Breaking

[![R-CMD-check](https://github.com/akersting/jitterRANN/actions/workflows/r.yml/badge.svg)](https://github.com/akersting/jitterRANN/actions/workflows/r.yml)

This is a “fork” of [RANN](https://github.com/jefferislab/RANN) v2.5
which adds random tie breaking to the `standard` search type with `kd`
trees. It is *as if* we added some jitter (i.e. some small amount of
noise) to the data, hence the name of this package. Note though that
this implementation uses an *exact* algorithm to break ties at random.

## Example

``` r
data <- data.frame(
  x = c(rep(c(1, 2, 3), each = 5)),
  y = c(rep(c(1, 2, 3), each = 5))
)

query <- data.frame(
  x = rep(1, 10),
  y = rep(1, 10)
)

print(data)
```

    ##    x y
    ## 1  1 1
    ## 2  1 1
    ## 3  1 1
    ## 4  1 1
    ## 5  1 1
    ## 6  2 2
    ## 7  2 2
    ## 8  2 2
    ## 9  2 2
    ## 10 2 2
    ## 11 3 3
    ## 12 3 3
    ## 13 3 3
    ## 14 3 3
    ## 15 3 3

``` r
print(query)
```

    ##    x y
    ## 1  1 1
    ## 2  1 1
    ## 3  1 1
    ## 4  1 1
    ## 5  1 1
    ## 6  1 1
    ## 7  1 1
    ## 8  1 1
    ## 9  1 1
    ## 10 1 1

The `RANN` packages returns for each of the 10 identical query points
the exact same results:

``` r
RANN::nn2(data, query, k = 8)
```

    ## $nn.idx
    ##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
    ##  [1,]    5    4    3    2    1    6    7    8
    ##  [2,]    5    4    3    2    1    6    7    8
    ##  [3,]    5    4    3    2    1    6    7    8
    ##  [4,]    5    4    3    2    1    6    7    8
    ##  [5,]    5    4    3    2    1    6    7    8
    ##  [6,]    5    4    3    2    1    6    7    8
    ##  [7,]    5    4    3    2    1    6    7    8
    ##  [8,]    5    4    3    2    1    6    7    8
    ##  [9,]    5    4    3    2    1    6    7    8
    ## [10,]    5    4    3    2    1    6    7    8
    ## 
    ## $nn.dists
    ##       [,1] [,2] [,3] [,4] [,5]     [,6]     [,7]     [,8]
    ##  [1,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [2,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [3,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [4,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [5,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [6,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [7,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [8,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [9,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ## [10,]    0    0    0    0    0 1.414214 1.414214 1.414214

While this is technically correct, many algorithms will run into issues
with such results. E.g., I originally created `jitterRANN` for the use
in a Predictive Mean Matching implementation. Using `RANN` here could
result in severely biased imputations.

Note that it is not sufficient to permute points (with the same
distances) afterwards, since we would still completely lack points 9 and
10, which are just as good as points 6 to 8.

Here is what `jitterRANN` returns:

``` r
set.seed(156)
jitterRANN::nn2(data, query, k = 8)
```

    ## $nn.idx
    ##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8]
    ##  [1,]    2    5    4    1    3   10    9    7
    ##  [2,]    2    3    4    1    5   10    9    8
    ##  [3,]    5    4    1    3    2    7   10    8
    ##  [4,]    1    3    5    4    2   10    7    9
    ##  [5,]    3    5    1    2    4   10    9    7
    ##  [6,]    3    4    2    5    1    6    8   10
    ##  [7,]    4    2    1    3    5    6    7   10
    ##  [8,]    1    3    4    2    5    7    6    9
    ##  [9,]    1    2    3    5    4    6    9    8
    ## [10,]    1    5    4    3    2    6    7   10
    ## 
    ## $nn.dists
    ##       [,1] [,2] [,3] [,4] [,5]     [,6]     [,7]     [,8]
    ##  [1,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [2,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [3,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [4,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [5,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [6,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [7,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [8,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ##  [9,]    0    0    0    0    0 1.414214 1.414214 1.414214
    ## [10,]    0    0    0    0    0 1.414214 1.414214 1.414214

Let’s verify the results a bit more by looking at the relative
distribution of the neighbours:

``` r
query <- data.frame(
  x = rep(1, 100000),
  y = rep(1, 100000)
)

res <- jitterRANN::nn2(data, query, k = 8)

for (j in 1:8) {
  cat("\n", j, ". neighbour:\n", sep = "")
  print(prop.table(table(res[["nn.idx"]][, j])))
}
```

    ## 
    ## 1. neighbour:
    ## 
    ##       1       2       3       4       5 
    ## 0.19834 0.19999 0.20258 0.19963 0.19946 
    ## 
    ## 2. neighbour:
    ## 
    ##       1       2       3       4       5 
    ## 0.20239 0.19955 0.19877 0.19959 0.19970 
    ## 
    ## 3. neighbour:
    ## 
    ##       1       2       3       4       5 
    ## 0.20079 0.20071 0.20001 0.20102 0.19747 
    ## 
    ## 4. neighbour:
    ## 
    ##       1       2       3       4       5 
    ## 0.20112 0.19919 0.19794 0.19983 0.20192 
    ## 
    ## 5. neighbour:
    ## 
    ##       1       2       3       4       5 
    ## 0.19736 0.20056 0.20070 0.19993 0.20145 
    ## 
    ## 6. neighbour:
    ## 
    ##       6       7       8       9      10 
    ## 0.20142 0.19948 0.19920 0.19932 0.20058 
    ## 
    ## 7. neighbour:
    ## 
    ##       6       7       8       9      10 
    ## 0.19733 0.20234 0.20103 0.20076 0.19854 
    ## 
    ## 8. neighbour:
    ## 
    ##       6       7       8       9      10 
    ## 0.20095 0.19841 0.19918 0.20045 0.20101

## Performance

If there are no ties to break, both implementations are equally fast:

``` r
data <- data.frame(
  x = runif(1e5),
  y = runif(1e5)
)

query <- data.frame(
  x = runif(1e3),
  y = runif(1e3)
)

bench <- microbenchmark::microbenchmark(
  RANN = RANN::nn2(data, query, k = 10),
  jitterRANN = jitterRANN::nn2(data, query, k = 10),
  times = 10
)

withr::with_options(
  list(digits = 3),
  print(bench)
)
```

    ## Unit: milliseconds
    ##        expr  min   lq mean median   uq  max neval
    ##        RANN 75.9 76.6 77.4   77.2 77.8 80.1    10
    ##  jitterRANN 76.1 76.3 78.3   77.5 79.1 85.2    10

If there is a high number of ties, this has a measurable performance
impact, but I found it still acceptable also for practical use cases
with big data:

``` r
data <- data.frame(
  x = rep(runif(1e3), 1e2),
  y = rep(runif(1e3), 1e2)
)

query <- data.frame(
  x = runif(1e3),
  y = runif(1e3)
)

bench <- microbenchmark::microbenchmark(
  RANN = RANN::nn2(data, query, k = 10),
  jitterRANN = jitterRANN::nn2(data, query, k = 10),
  times = 10
)

withr::with_options(
  list(digits = 3),
  print(bench)
)
```

    ## Unit: milliseconds
    ##        expr   min    lq  mean median    uq   max neval
    ##        RANN  64.6  66.2  67.6   68.3  68.8  69.9    10
    ##  jitterRANN 128.3 130.2 136.2  132.3 141.3 157.3    10
