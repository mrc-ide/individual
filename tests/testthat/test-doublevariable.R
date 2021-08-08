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
})

test_that("getting indices of DoubleVariable in a range works", {
  dat <- seq(from=0,to=1,by=0.01)
  var <- DoubleVariable$new(dat)
  
  empty <- var$get_index_of(a = 500,b = 600)
  full <- var$get_index_of(a = 0.65,b = 0.89)
  match_full <- which(dat>=0.65 & dat<=0.89)
  
  expect_length(empty$to_vector(), 0)
  expect_equal(full$to_vector(), match_full)
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

test_that("getting values from DoubleVariable with bitset of incompatible size fails", {
  x <- DoubleVariable$new(initial_values = 1:100)
  b <- Bitset$new(1000)$insert(90:110)
  expect_error(x$get_values(b))
})