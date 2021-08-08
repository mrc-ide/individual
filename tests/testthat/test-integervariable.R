test_that("getting variables works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))
  sequence_2 <- IntegerVariable$new(seq_len(size) + 10)
  
  expect_equal(sequence$get_values(), 1:10)
  expect_equal(sequence_2$get_values(), (1:10) + 10)
})

test_that("getting variables with repeats works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))
  
  expect_equal(sequence$get_values(c(1, 1, 2, 2)), c(1, 1, 2, 2))
})

test_that("getting variables at an index works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))
  sequence_2 <- IntegerVariable$new(seq_len(size) + 10)
  
  expect_equal(sequence$get_values(NULL), 1:10)
  expect_error(sequence_2$get_values(5:15))
  expect_equal(sequence_2$get_values(5:10), 15:20)
})

test_that("getting a set of IntegerVariable indices which exist works", {
  
  vals <- 5:10
  intvar <- IntegerVariable$new(vals)
  
  set <- 6:8
  indices <- intvar$get_index_of(set = set)  
  
  expect_equal(indices$to_vector(), 2:4)
  
  set <- 10
  indices <- intvar$get_index_of(set = set)
  expect_equal(indices$to_vector(), 6)
})

test_that("getting a set of IntegerVariable indices which do not exist works", {
  
  vals <- 5:10
  intvar <- IntegerVariable$new(vals)
  
  set <- 1e3:1.001e3
  indices <- intvar$get_index_of(set = set)  
  
  expect_length(indices$to_vector(), 0)
  
  set <- -5
  indices <- intvar$get_index_of(set = set)  
  
  expect_length(indices$to_vector(), 0)
})

test_that("getting indices within bounds of IntegerVariable which exist works", {
  
  vals <- 5:10
  intvar <- IntegerVariable$new(vals)
  
  a <- 6
  b <- 8
  indices <- intvar$get_index_of(a = a, b = b)  
  
  expect_equal(indices$to_vector(), 2:4)
})

test_that("getting indices within bounds of IntegerVariable which do not exist works", {
  
  vals <- 5:10
  intvar <- IntegerVariable$new(vals)
  
  a <- 1e3
  b <- 1.001e3
  indices <- intvar$get_index_of(a = a, b = b)  
  
  expect_length(indices$to_vector(), 0)
})

test_that("getting size of a set of IntegerVariable values which exist works", {
  intvar <- IntegerVariable$new(-10:10)
  set <- c(-2,-1,1,2) 
  expect_equal(intvar$get_size_of(set = set), 4)
  
  set <- 10
  expect_equal(intvar$get_size_of(set = set), 1)
})

test_that("getting size of a set of IntegerVariable values which do not exist works", {
  intvar <- IntegerVariable$new(-10:10)
  set <- -20:-15
  expect_equal(intvar$get_size_of(set = set), 0)
  
  set <- 50
  expect_equal(intvar$get_size_of(set = set), 0)
})

test_that("getting size of a interval of IntegerVariable values which exist works", {
  intvar <- IntegerVariable$new(-10:10)
  a <- 5
  b <- 7
  expect_equal(intvar$get_size_of(a = a, b = b), 3)
})

test_that("getting size of a interval of IntegerVariable values which do not exist works", {
  intvar <- IntegerVariable$new(-10:10)
  a <- -50
  b <- -40
  expect_equal(intvar$get_size_of(a = a, b = b), 0)
})

test_that("using a, b in IntegerVariable size and index methods works", {
  intvar <- IntegerVariable$new(rep(1:10,each=3))
  a <- 5
  b <- 5
  expect_equal(intvar$get_size_of(a = a, b = b), 3)
  expect_error(intvar$get_size_of(a = 7,b = 4))
  
  expect_equal(intvar$get_index_of(a = a, b = b)$to_vector(), c(13, 14, 15))
  expect_error(intvar$get_index_of(a = 7,b = 4))
})

test_that("getting values from IntegerVariable with bitset of incompatible size fails", {
  x <- IntegerVariable$new(initial_values = 1:100)
  b <- Bitset$new(1000)$insert(90:110)
  expect_error(x$get_values(b))
})