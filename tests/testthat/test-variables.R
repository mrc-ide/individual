test_that("getting the state works", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_setequal(state$get_index_of('S')$to_vector(), seq(10))
})

test_that("Getting multiple states works", {
  state <- CategoricalVariable$new(
    c('S', 'I', 'R'),
    c(rep('S', 10), rep('I', 100), rep('R', 20))
  )

  expect_setequal(
    state$get_index_of(c('S', 'R'))$to_vector(),
    c(seq(10), seq(20) + 110)
  )
})

test_that("getting a non registered state index fails", {
  state <- CategoricalVariable$new(
    c('S', 'I'),
    c(rep('S', 10), rep('I', 100))
  )

  expect_error(
    state$get_index_of('R'),
    '*'
  )
})

test_that("getting the size of CategoricalVariable category works", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_equal(state$get_size_of('S'), 10)
})

test_that("getting the size of CategoricalVariable category which does not exist errors gracefully", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_error(state$get_size_of('X'))
})

test_that("can retrieve categories of CategoricalVariable", {
  values <- c("S","E","I","R")
  var <- CategoricalVariable$new(categories = values,initial_values = rep(values,2))
  expect_setequal(categorical_variable_get_categories(var$.variable), values)
})

test_that("Queuing invalid category errors", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_error(variable$queue_update("X", Bitset$new(1)$insert(1)),
               '*'
  )
})

test_that("getting variables works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  sequence_2 <- DoubleVariable$new(seq_len(size) + 10)

  expect_equal(sequence$get_values(), 1:10)
  expect_equal(sequence_2$get_values(), (1:10) + 10)
})

test_that("getting double variables with repeats works", {
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
