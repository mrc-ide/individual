test_that("Creating IntegerVariables errors with bad input", {
  expect_error(IntegerVariable$new(NULL))
  expect_error(IntegerVariable$new(NaN))
  expect_error(IntegerVariable$new(c(1,NaN)))
  expect_error(IntegerVariable$new(NA))
  expect_error(IntegerVariable$new(c(1,NA)))
  expect_error(IntegerVariable$new(Inf))
  expect_error(IntegerVariable$new(c(1,Inf)))
  expect_error(IntegerVariable$new(-Inf))
  expect_error(IntegerVariable$new(c(1,-Inf)))
  expect_error(IntegerVariable$new("1"))
})

test_that("IntegerVariable get values returns correct values without index", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  expect_equal(variable$get_values(), 1:10)
  
  variable <- IntegerVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(), (1:10) + 10)
  
  variable <- IntegerVariable$new(seq_len(size))
  expect_equal(variable$get_values(c(1, 1, 2, 2)), c(1, 1, 2, 2))
})

test_that("IntegerVariable get values returns correct values with vector index", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  expect_equal(variable$get_values(NULL), 1:10)
  
  variable <- IntegerVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(5:10), 15:20)
})

test_that("IntegerVariable get values returns correct values with bitset index", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size) + 10)
  expect_equal(variable$get_values(Bitset$new(size = size)$insert(5:10)), 15:20)
})

test_that("IntegerVariable get values fails with incorrect index", {
  variable <- IntegerVariable$new(initial_values = 1:100)
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

test_that("IntegerVariable get index of set works correctly", {
  variable <- IntegerVariable$new(5:10)
  
  indices <- variable$get_index_of(set = 6:8)  
  expect_equal(indices$to_vector(), 2:4)
  
  indices <- variable$get_index_of(set = 10)
  expect_equal(indices$to_vector(), 6)
  
  indices <- variable$get_index_of(set = 1e3:1.001e3)  
  expect_equal(indices$size(), 0)
  
  indices <- variable$get_index_of(set = -5)
  expect_equal(indices$size(), 0)
  
  indices <- variable$get_index_of(set = integer(0))
  expect_equal(indices$size(), 0)
  
  indices <- variable$get_index_of(set = numeric(0))
  expect_equal(indices$size(), 0)
  
  variable <- IntegerVariable$new(-10:10)
  indices <- variable$get_index_of(set = c(-2,-1,1,2))
  expect_equal(indices$to_vector(), c(9, 10, 12, 13))
})

test_that("IntegerVariable get index of set fails with incorrect set", {
  variable <- IntegerVariable$new(1:10)
  expect_error(variable$get_index_of(set = Inf))
  expect_error(variable$get_index_of(set = -Inf))
  expect_error(variable$get_index_of(set = NULL))
  expect_error(variable$get_index_of(set = NA))
  expect_error(variable$get_index_of(set = NaN))
  expect_error(variable$get_index_of(set = "5"))
})


test_that("IntegerVariable get index of bounds [a,b] works correctly", {
  variable <- IntegerVariable$new(5:10)
  
  indices <- variable$get_index_of(a = 6, b = 8)  
  expect_equal(indices$to_vector(), 2:4)
  
  indices <- variable$get_index_of(a = 7, b = 7)
  expect_equal(indices$to_vector(), 3)
  
  indices <- variable$get_index_of(a = 1e3, b = 1.001e3)
  expect_length(indices$to_vector(), 0)
})

test_that("IntegerVariable get index of bounds [a,b] fails with incorrect bounds", {
  variable <- IntegerVariable$new(5:10)
  
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
})

test_that("IntegerVariable get size of set works correctly", {
  variable <- IntegerVariable$new(-10:10)
  set <- c(-2,-1,1,2) 
  expect_equal(variable$get_size_of(set = set), length(set))
  
  expect_equal(variable$get_size_of(set = -20:-15), 0)
  expect_equal(variable$get_size_of(set = 10), 1)
  expect_equal(variable$get_size_of(set = numeric(0)), 0)
  expect_equal(variable$get_size_of(set = integer(0)), 0)
})

test_that("IntegerVariable get size of set fails with incorrect input", {
  variable <- IntegerVariable$new(-10:10)
  expect_error(variable$get_size_of(set = NULL))
  expect_error(variable$get_size_of(set = NA))
  expect_error(variable$get_size_of(set = NaN))
  expect_error(variable$get_size_of(set = Inf))
  expect_error(variable$get_size_of(set = -Inf))
  expect_error(variable$get_size_of(set = "5"))
})

test_that("IntegerVariable get size of set in bounds [a,b] works correctly", {
  variable <- IntegerVariable$new(-10:10)
  expect_equal(variable$get_size_of(a = 5, b = 7), 3)
  expect_equal(variable$get_size_of(a = 5, b = 5), 1)
  expect_equal(variable$get_size_of(a = -10, b = -5), 6)
  expect_equal(variable$get_size_of(a = -50, b = -40), 0)
})

test_that("IntegerVariable get size of set in bounds [a,b] fails with incorrect input", {
  variable <- IntegerVariable$new(-10:10)
  
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
})

test_that("IntegerVariable get size and index of set in bounds [a,b] and set gives same answer for equal intervals", {
  variable <- IntegerVariable$new(-10:10)
  expect_equal(variable$get_size_of(a = 5, b = 7), variable$get_size_of(set = 5:7))
  expect_equal(variable$get_index_of(a = 5, b = 7)$to_vector(), variable$get_index_of(set = 5:7)$to_vector())
})
