test_that("extending RaggedDouble returns the new values", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  expect_equal(x$get_values(), vals)
  x$queue_extend(values =   as.list(seq_len(size)+10))
  x$.resize()
  expect_equal(x$get_values(), as.list(1:20))
})

test_that("shrinking RaggedDouble removes values (bitset)", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  x$queue_shrink(index = Bitset$new(size)$insert(1:5))
  x$.resize()
  expect_equal(x$get_values(), as.list(6:10))
})

test_that("shrinking RaggedDouble removes values (vector)", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  expect_equal(x$get_values(), vals)
  x$queue_shrink(index = 6:10)
  x$.resize()
  expect_equal(x$get_values(), as.list(1:5))
})

test_that("resizing variables returns the correct size", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  expect_equal(x$size(), 10)
  x$queue_extend(values = as.list(seq_len(size) + 10))
  x$queue_shrink(index = 5:10)
  x$.resize()
  expect_equal(x$size(), 14)
})

test_that("RaggedDouble shrinks are combined", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  x$queue_shrink(index = Bitset$new(size)$insert(1:5))
  x$queue_shrink(index = Bitset$new(size)$insert(3:8))
  x$.resize()
  expect_equal(x$get_values(), as.list(9:10))
})

test_that("RaggedDouble shrinks are applied before extentions", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  x$queue_shrink(index = 5:10)
  x$queue_extend(values = as.list(seq_len(size) + 10))
  x$queue_shrink(index = 1:5)
  x$queue_extend(values = as.list(seq_len(size) + 20))
  x$.resize()
  expect_equal(x$get_values(), as.list(11:30))
})

test_that("invalid shrinking operations error at queue time", {
  size <- 10
  vals <- as.list(seq_len(size))
  x <- RaggedDouble$new(vals)
  expect_error(x$queue_shrink(index = 1:20))
  expect_error(x$queue_shrink(index = -1:20))
  expect_error(x$queue_shrink(index = Bitset$new(size + 1)$insert(1:20)))
})
