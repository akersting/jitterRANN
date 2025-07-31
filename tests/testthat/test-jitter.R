context("jitter")

test_that("ties are broken correctly", {
  X <- c(rep(0, 3), rep(1, 3), 2)
  Y <- matrix(rep(0, 10), 1000)

  for (k in 1:3) {
    res <- nn2(X, Y, k)
    expect_true(all(res$nn.dists == 0))
    expect_true(all(res$nn.idx %in% 1:3))
    expect_true(all(apply(res$nn.idx, 2, function(col) {
      length(unique(col)) != 1
    })))
  }

  for (k in 4:6) {
    res <- nn2(X, Y, k)
    expect_true(all(res$nn.dists[, 1:3] == 0))
    expect_true(all(res$nn.dists[, 4:k] == 1))
    expect_true(all(res$nn.idx[, 1:3] %in% 1:3))
    expect_true(all(res$nn.idx[, 4:k] %in% 4:6))
    expect_true(all(apply(res$nn.idx, 2, function(col) {
      length(unique(col)) != 1
    })))
  }

  k <- 7

  res <- nn2(X, Y, k)
  expect_true(all(res$nn.dists[, 1:3] == 0))
  expect_true(all(res$nn.dists[, 4:6] == 1))
  expect_true(all(res$nn.dists[, 7] == 2))
  expect_true(all(res$nn.idx[, 1:3] %in% 1:3))
  expect_true(all(res$nn.idx[, 4:6] %in% 4:6))
  expect_true(all(res$nn.idx[, 7] %in% 7))
  expect_true(all(apply(res$nn.idx[, 1:6], 2, function(col) {
    length(unique(col)) != 1
  })))
  expect_true(length(unique(res$nn.idx[, 7])) == 1)
})

test_that("ties are broken correctly in edge cases", {
  X <- 0
  Y <- 0
  expect_silent(nn2(X, Y, 1))

  # two donors, k = 1, same dist
  X <- c(1, 1)
  Y <- rep(0, 1000)
  expect_true(length(unique(nn2(X, Y, 1)$nn.idx[ , 1])) == 2)

  # two donors, k = 2, different dist
  res <- nn2(X, Y, 2)$nn.idx
  expect_true(length(unique(res[, 1])) == 2)
  expect_true(length(unique(res[, 2])) == 2)

  # two donors, k = 1, different dist
  X <- c(1, 2)
  Y <- rep(0, 1000)
  expect_true(all(nn2(X, Y, 1)$nn.idx[, 1] == 1))

  # two donors, k = 2, different dist
  res <- nn2(X, Y, 2)$nn.idx
  expect_true(all(res[, 1] == 1))
  expect_true(all(res[, 2] == 2))
})
