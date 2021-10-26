test_that("Creating DoubleVariables errors with bad input", {
  expect_error(DoubleVariable$new(NULL))
  expect_error(DoubleVariable$new(NA))
  expect_error(DoubleVariable$new("1"))
})

test_that("DoubleVariable get values returns correct values without index", {
  size <- 10
  variable <- DoubleVariable$new(seq_len(size))
  expect_equal(variable$get_values(), 1:10)
  
  variable <- DoubleVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(), (1:10) + 10)
  
  variable <- DoubleVariable$new(seq_len(size))
  expect_equal(variable$get_values(c(1, 1, 2, 2)), c(1, 1, 2, 2))
})

test_that("DoubleVariable get values returns correct values with vector index", {
  size <- 10
  variable <- DoubleVariable$new(seq_len(size))
  expect_equal(variable$get_values(NULL), 1:10)
  
  variable <- DoubleVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(5:10), 15:20)
})

test_that("DoubleVariable get values returns correct values with bitset index", {
  size <- 10
  variable <- DoubleVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(Bitset$new(size = size)$insert(5:10)), 15:20)
})

test_that("DoubleVariable get values fails with incorrect index", {
  variable <- DoubleVariable$new(initial_values = 1:100)
  b <- Bitset$new(1000)
  expect_error(variable$get_values(b))
  expect_error(variable$get_values(b$insert(90:110)))
  expect_error(variable$get_values(90:110))
  expect_error(variable$get_values(-5:2))
  expect_error(variable$get_values(NaN))
  expect_error(variable$get_values(NA))
  expect_error(variable$get_values(Inf))
  expect_error(variable$get_values("10"))
})

test_that("DoubleVariable get index of bounds [a,b] works correctly", {
  variable <- DoubleVariable$new(5:10)
  
  indices <- variable$get_index_of(a = 6, b = 8)  
  expect_equal(indices$to_vector(), 2:4)
  
  indices <- variable$get_index_of(a = 6.9, b = 7.1)
  expect_equal(indices$to_vector(), 3)
  
  indices <- variable$get_index_of(a = 1e3, b = 1.001e3)
  expect_length(indices$to_vector(), 0)
  
  data <- seq(from = 0, to = 1, by = 0.01)
  variable <- DoubleVariable$new(data)
  
  empty <- variable$get_index_of(a = 500, b = 600)
  full <- variable$get_index_of(a = 0.65, b = 0.89)
  match_full <- which(data>=0.65 & data<=0.89)
  
  expect_length(empty$to_vector(), 0)
  expect_equal(full$to_vector(), match_full)
})

test_that("DoubleVariable get index of bounds [a,b] fails with incorrect bounds", {
  variable <- DoubleVariable$new(5:10)
  
  expect_error(variable$get_index_of(a = a, b = NULL))
  expect_error(variable$get_index_of(a = a, b = a - 10))
  expect_error(variable$get_index_of(a = a, b = NA))
  expect_error(variable$get_index_of(a = a, b = NaN))
  expect_error(variable$get_index_of(a = a, b = Inf))
  expect_error(variable$get_index_of(a = a, b = -Inf))
  
  expect_error(variable$get_index_of(a = NULL, b = b))
  expect_error(variable$get_index_of(a = b + 10, b = b))
  expect_error(variable$get_index_of(a = NA, b = b))
  expect_error(variable$get_index_of(a = NaN, b = b))
  expect_error(variable$get_index_of(a = Inf, b = b))
  expect_error(variable$get_index_of(a = -Inf, b = b))
  
  expect_error(variable$get_index_of(a = integer(0), b = b))
  expect_error(variable$get_index_of(a = numeric(0), b = b))
  
  expect_error(variable$get_index_of(a = a, b = integer(0)))
  expect_error(variable$get_index_of(a = a, b = integer(0)))
  
  expect_error(variable$get_index_of(a = integer(0), b = integer(0)))
  expect_error(variable$get_index_of(a = numeric(0), b = numeric(0)))
  
  data <- seq(from = 0, to = 1, by = 0.01)
  variable <- DoubleVariable$new(data)
  
  expect_error(variable$get_index_of(a = 50,b = 10))
  expect_error(variable$get_index_of(a = 0,b = -5))
})


test_that("DoubleVariable get size of set in bounds [a,b] works correctly", {
  variable <- DoubleVariable$new(-10:10)
  expect_equal(variable$get_size_of(a = 5, b = 7), 3)
  expect_equal(variable$get_size_of(a = 4.9, b = 5.1), 1)
  expect_equal(variable$get_size_of(a = -10, b = -5), 6)
  expect_equal(variable$get_size_of(a = -50, b = -40), 0)
  
  data <- seq(from = 0, to = 1, by = 0.01)
  variable <- DoubleVariable$new(data)
  
  empty <- variable$get_size_of(a = 500,b = 600)
  full <- variable$get_size_of(a = 0.65,b = 0.89)
  match_full <- sum(data>=0.65 & data<=0.89)
  
  expect_equal(empty, 0)
  expect_equal(full, match_full)
  
})

test_that("DoubleVariable get size of set in bounds [a,b] fails with incorrect input", {
  variable <- DoubleVariable$new(-10:10)
  
  expect_error(variable$get_size_of(a = a, b = NULL))
  expect_error(variable$get_size_of(a = a, b = a - 10))
  expect_error(variable$get_size_of(a = a, b = NA))
  expect_error(variable$get_size_of(a = a, b = NaN))
  expect_error(variable$get_size_of(a = a, b = Inf))
  expect_error(variable$get_size_of(a = a, b = -Inf))
  
  expect_error(variable$get_size_of(a = NULL, b = b))
  expect_error(variable$get_size_of(a = b + 10, b = b))
  expect_error(variable$get_size_of(a = NA, b = b))
  expect_error(variable$get_size_of(a = NaN, b = b))
  expect_error(variable$get_size_of(a = Inf, b = b))
  expect_error(variable$get_size_of(a = -Inf, b = b))
  
  expect_error(variable$get_size_of(a = integer(0), b = b))
  expect_error(variable$get_size_of(a = numeric(0), b = b))
  
  expect_error(variable$get_size_of(a = a, b = integer(0)))
  expect_error(variable$get_size_of(a = a, b = integer(0)))
  
  expect_error(variable$get_size_of(a = integer(0), b = integer(0)))
  expect_error(variable$get_size_of(a = numeric(0), b = numeric(0)))
  
  data <- seq(from = 0, to = 1, by = 0.01)
  variable <- DoubleVariable$new(data)
  
  expect_error(variable$get_size_of(a = 50,b = 10))
  expect_error(variable$get_size_of(a = 0,b = -5))
})
