test_that("getting variables works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  sequence_2 <- DoubleVariable$new(seq_len(size) + 10)
  
  expect_equal(sequence$get_values(), 1:10)
  expect_equal(sequence_2$get_values(), (1:10) + 10)
})

test_that("getting variables with repeats works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  
  expect_equal(sequence$get_values(c(1, 1, 2, 2)), c(1, 1, 2, 2))
})

test_that("getting variables at an index works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  sequence_2 <- DoubleVariable$new(seq_len(size) + 10)
  
  expect_equal(sequence$get_values(NULL), 1:10)
  expect_error(sequence_2$get_values(5:15))
  expect_equal(sequence_2$get_values(5:10), 15:20)
  
  b <- Bitset$new(size)$insert(5:10)
  expect_equal(sequence_2$get_values(b), 15:20)
})

test_that("getting indices of DoubleVariable in a range works", {
  dat <- seq(from=0,to=1,by=0.01)
  var <- DoubleVariable$new(dat)
  
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
  var <- DoubleVariable$new(dat)
  
  empty <- var$get_size_of(a = 500,b = 600)
  full <- var$get_size_of(a = 0.65,b = 0.89)
  match_full <- sum(dat>=0.65 & dat<=0.89)
  
  expect_equal(empty, 0)
  expect_equal(full, match_full)
})

test_that("getting values from DoubleVariable with incompatible index fails", {
  x <- DoubleVariable$new(initial_values = 1:100)
  b <- Bitset$new(1000)$insert(90:110)
  expect_error(x$get_values(b))
  expect_error(x$get_values(90:110))
  expect_error(x$get_values(-5:2))
})

test_that("queueing updates with bad inputs fails or does nothing", {
  x <- DoubleVariable$new(initial_values = 1:10)
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
  x <- DoubleVariable$new(initial_values = 1:10)
  expect_error(x$get_size_of(a = 5))
  expect_error(x$get_size_of(b = 5))
})

test_that("get index of method fails correctly with bad inputs", {
  x <- DoubleVariable$new(initial_values = 1:10)
  expect_error(x$get_index_of(a = 5))
  expect_error(x$get_index_of(b = 5))
})