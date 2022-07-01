SIR <- c('S', 'I', 'R')

test_that("CategoricalVariable extending variables returns the new values", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  expect_equal(x$get_index_of('S')$to_vector(), 1:10)
  x$queue_extend(values = c('S', 'I', 'R'))
  x$.resize()
  expect_equal(x$get_index_of('S')$to_vector(), 1:11)
  expect_equal(x$get_index_of('I')$to_vector(), 12)
  expect_equal(x$get_index_of('R')$to_vector(), 13)
})

test_that("CategoricalVariable shrinking variables removes values (bitset)", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  x$queue_shrink(index = Bitset$new(10)$insert(1:5))
  x$.resize()
  expect_equal(x$get_index_of('S')$to_vector(), 1:5)
})

test_that("CategoricalVariable shrinking variables removes values (vector)", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  x$queue_shrink(index = 6:10)
  x$.resize()
  expect_equal(x$get_index_of('S')$to_vector(), 1:5)
})

test_that("CategoricalVariable resizing variables returns the correct size", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  expect_equal(x$size(), 10)
  x$queue_extend(values = rep('S', 10))
  x$queue_shrink(index = 5:10)
  x$.resize()
  expect_equal(x$size(), 14)
})


test_that("CategoricalVariable shrinks are combined", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  x$queue_shrink(index = 1:5)
  x$queue_shrink(index = 3:8)
  x$.resize()
  expect_equal(x$get_index_of('S')$to_vector(), 1:2)
})

test_that("CategoricalVariable shrinks are applied before extentions", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  x$queue_shrink(index = 5:10)
  x$queue_extend(values = rep('I', 10))
  x$queue_shrink(index = 1:5)
  x$queue_extend(values = rep('R', 10))
  x$.resize()
  expect_equal(x$get_index_of('S')$to_vector(), double(0))
  expect_equal(x$get_index_of('I')$to_vector(), 1:10)
  expect_equal(x$get_index_of('R')$to_vector(), 11:20)
})

test_that("CategoricalVariable invalid shrinking operations error at queue time", {
  x <- CategoricalVariable$new(SIR, rep('S', 10))
  expect_error(x$queue_shrink(index = 1:20))
  expect_error(x$queue_shrink(index = -1:5))
  expect_error(x$queue_shrink(index = Bitset$new(size + 1)$insert(1:20)))
})
