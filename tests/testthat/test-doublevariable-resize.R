test_that("DoubleVariable extending variables returns the new values", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  expect_equal(x$get_values(), 1:10)
  x$queue_extend(values = seq_len(size) + 10)
  x$.resize()
  expect_equal(x$get_values(), 1:20)
})

test_that("DoubleVariable shrinking variables removes values (bitset)", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  x$queue_shrink(index = Bitset$new(size)$insert(1:5))
  x$.resize()
  expect_equal(x$get_values(), 6:10)
})

test_that("DoubleVariable shrinking variables removes values (vector)", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  expect_equal(x$get_values(), 1:10)
  x$queue_shrink(index = 6:10)
  x$.resize()
  expect_equal(x$get_values(), 1:5)
})

test_that("DoubleVariable resizing variables returns the correct size", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  expect_equal(x$size(), 10)
  x$queue_extend(values = seq_len(size) + 10)
  x$queue_shrink(index = 5:10)
  x$.resize()
  expect_equal(x$size(), 14)
})

test_that("DoubleVariable shrinks are combined", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  x$queue_shrink(index = Bitset$new(size)$insert(1:5))
  x$queue_shrink(index = Bitset$new(size)$insert(3:8))
  x$.resize()
  expect_equal(x$get_values(), 9:10)
})

test_that("DoubleVariable shrinks are applied before extentions", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  x$queue_shrink(index = 5:10)
  x$queue_extend(values = seq_len(size) + 10)
  x$queue_shrink(index = 1:5)
  x$queue_extend(values = seq_len(size) + 20)
  x$.resize()
  expect_equal(x$get_values(), 11:30)
})

test_that("DoubleVariable invalid shrinking operations error at queue time", {
  size <- 10
  x <- DoubleVariable$new(seq_len(size))
  expect_error(x$queue_shrink(index = 1:20))
  expect_error(x$queue_shrink(index = -1:20))
  expect_error(x$queue_shrink(index = Bitset$new(size + 1)$insert(1:20)))
})
