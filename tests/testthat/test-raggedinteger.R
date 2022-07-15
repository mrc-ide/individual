test_that("Creating RaggedInteger errors with bad input", {
  expect_error(RaggedInteger$new(NULL))
  expect_error(RaggedInteger$new(list("1")))
  expect_error(RaggedInteger$new(list(NA)))
  expect_error(RaggedInteger$new(list(1:5,NA)))
  expect_error(RaggedInteger$new(list(1:5,FALSE)))
})

test_that("RaggedInteger get values returns correct values without index", {
  size <- 10
  vals <- replicate(n = size, expr = rpois(n = 5, lambda = 10), simplify = FALSE)
  variable <- RaggedInteger$new(vals)
  expect_equal(variable$get_values(), vals)
  
  vals[[11]] <- integer(0)
  variable <- RaggedInteger$new(vals)
  expect_equal(variable$get_values(), vals)
  
  vals[[11]] <- numeric(0)
  variable <- RaggedInteger$new(vals)
  expect_equal(variable$get_values(), vals)
})

test_that("RaggedInteger get values returns correct values with vector index", {
  size <- 10
  vals <- replicate(n = size, expr = rpois(n = 5, lambda = 10), simplify = FALSE)
  variable <- RaggedInteger$new(vals)
  
  for (i in 1:20) {
    ix <- sample(x = 1:size, size = sample.int(n = size, size = 1))
    expect_equal(variable$get_values(ix), vals[ix])
  }
})

test_that("RaggedInteger get values returns correct values with bitset index", {
  size <- 10
  vals <- replicate(n = size, expr = rpois(n = 5, lambda = 10), simplify = FALSE)
  variable <- RaggedInteger$new(vals)
  
  for (i in 1:20) {
    ix <- sort(sample(x = 1:size, size = sample.int(n = size, size = 1)))
    bset <- Bitset$new(size)$insert(ix)
    expect_equal(variable$get_values(bset), vals[ix])
  }
})

test_that("RaggedInteger get values fails with incorrect index", {
  variable <- RaggedInteger$new(initial_values = as.list(1:100))
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

test_that("RaggedInteger get length returns correct values with vector index", {
  size <- 10
  vals <- replicate(n = size, expr = rpois(n = rpois(n = 1, lambda = 10), lambda = 10), simplify = FALSE)
  variable <- RaggedInteger$new(vals)
  
  for (i in 1:20) {
    ix <- sample(x = 1:size, size = sample.int(n = size, size = 1))
    expect_equal(variable$get_length(ix), vapply(vals[ix], length, integer(1)))
  }
})

test_that("RaggedInteger get length returns correct values with bitset index", {
  size <- 10
  vals <- replicate(n = size, expr = rpois(n = rpois(n = 1, lambda = 10), lambda = 10), simplify = FALSE)
  variable <- RaggedInteger$new(vals)
  
  for (i in 1:20) {
    ix <- sort(sample(x = 1:size, size = sample.int(n = size, size = 1)))
    bset <- Bitset$new(size)$insert(ix)
    expect_equal(variable$get_length(bset), vapply(vals[ix], length, integer(1)))
  }
})

test_that("RaggedInteger get values fails with incorrect index", {
  variable <- RaggedInteger$new(initial_values = as.list(1:100))
  b <- Bitset$new(1000)
  expect_error(variable$get_length(b))
  expect_error(variable$get_length(b$insert(90:110)))
  expect_error(variable$get_length(90:110))
  expect_error(variable$get_length(-5:2))
  expect_error(variable$get_length(NaN))
  expect_error(variable$get_length(NA))
  expect_error(variable$get_length(Inf))
  expect_error(variable$get_length("10"))
})
