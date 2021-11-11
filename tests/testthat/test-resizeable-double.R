test_that("getting resizeable variables works", {
  size <- 10
  sequence <- ResizeableDoubleVariable$new(seq_len(size))
  sequence_2 <- ResizeableDoubleVariable$new(seq_len(size) + 10)
  
  expect_equal(sequence$get_values(), 1:10)
  expect_equal(sequence_2$get_values(), (1:10) + 10)
})

test_that("extending variables returns the new values", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  expect_equal(x$get_values(), 1:10)
  x$queue_extend(values = seq_len(size) + 10)
  x$.update()
  expect_equal(x$get_values(), 1:20)
})

test_that("shrinking variables removes values (bitset)", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  x$queue_shrink(index = Bitset$new(size)$insert(1:5))
  x$.update()
  expect_equal(x$get_values(), 1:5)
})

test_that("shrinking variables removes values (vector)", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  expect_equal(x$get_values(), 1:10)
  x$queue_shrink(index = 5:10)
  x$.update()
  expect_equal(x$get_values(), 1:5)
})

test_that("resizing variables returns the correct size", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  expect_equal(x$size(), 10)
  x$queue_extend(values = seq_len(size) + 10)
  x$queue_shrink(index = 5:10)
  x$.update()
  expect_equal(x$size(), 15)
})

test_that("resizing operations preserve order", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  x$queue_shrink(index = 5:10)
  x$queue_extend(values = seq_len(size) + 10)
  x$queue_shrink(index = 1:5)
  x$queue_extend(values = seq_len(size) + 20)
  x$.update()
  expect_equal(x$get_values(), 10:30)
})

test_that("invalid shrinking operations error at queue time", {
  size <- 10
  x <- ResizeableDoubleVariable$new(seq_len(size))
  expect_error(x$queue_shrink(index = 1:20))
  expect_error(x$queue_shrink(index = -1:20))
  expect_error(x$queue_shrink(index = Bitset$new(size + 1)))
})

test_that("getting indices of DoubleVariable in a range works", {
  dat <- seq(from=0,to=1,by=0.01)
  var <- ResizeableDoubleVariable$new(dat)
  
  empty <- var$get_index_of(a = 500,b = 600)
  full <- var$get_index_of(a = 0.65,b = 0.89)
  match_full <- which(dat>=0.65 & dat<=0.89)
  
  expect_length(empty$to_vector(), 0)
  expect_equal(full$to_vector(), match_full)
  
  expect_error(var$get_size_of(a = 50,b = 10))
  expect_error(var$get_size_of(a = 0,b = -5))
})

test_that("getting size of DoubleVariable in a range works", {
  dat <- seq(from=0,to=1,by=0.01)
  var <- ResizeableDoubleVariable$new(dat)
  
  empty <- var$get_size_of(a = 500,b = 600)
  full <- var$get_size_of(a = 0.65,b = 0.89)
  match_full <- sum(dat>=0.65 & dat<=0.89)
  
  expect_equal(empty, 0)
  expect_equal(full, match_full)
})

test_that("getting values from DoubleVariable with incompatible index fails", {
  x <- ResizeableDoubleVariable$new(initial_values = 1:100)
  b <- Bitset$new(1000)$insert(90:110)
  expect_error(x$get_values(b))
  expect_error(x$get_values(90:110))
  expect_error(x$get_values(-5:2))
})

test_that("queueing updates with bad inputs fails or does nothing", {
  x <- ResizeableDoubleVariable$new(initial_values = 1:10)
  x$queue_update(values = numeric(0), index = 1:10)
  x$.update()
  expect_equal(x$get_values(), 1:10)
  
  x$queue_update(values = numeric(0), index = Bitset$new(10)$insert(1:3))
  x$.update()
  expect_equal(x$get_values(), 1:10)
  
  x$queue_update(values = 10, index = Bitset$new(0))
  x$.update()
  expect_equal(x$get_values(), 1:10)
  
  x$queue_update(values = 10, index = integer(0))
  x$.update()
  expect_equal(x$get_values(), 1:10)
  
  expect_error(x$queue_update(values = 10, index = -5:-3))
  
  x$queue_update(values = 10, index = Bitset$new(100))
  x$.update()
  expect_equal(x$get_values(), 1:10)
  
  expect_error(x$queue_update(values = 10, index = Bitset$new(100)$insert(1:50)))
})

test_that("get size of method fails correctly with bad inputs", {
  x <- ResizeableDoubleVariable$new(initial_values = 1:10)
  expect_error(x$get_size_of(a = 5))
  expect_error(x$get_size_of(b = 5))
})

test_that("get index of method fails correctly with bad inputs", {
  x <- ResizeableDoubleVariable$new(initial_values = 1:10)
  expect_error(x$get_index_of(a = 5))
  expect_error(x$get_index_of(b = 5))
})
