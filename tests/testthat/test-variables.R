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

test_that("getting variables works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  sequence_2 <- DoubleVariable$new(seq_len(size) + 10)

  expect_equal(sequence$get_values(), 1:10)
  expect_equal(sequence_2$get_values(), (1:10) + 10)
})

test_that("getting variables at an index works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  sequence_2 <- DoubleVariable$new(seq_len(size) + 10)

  expect_equal(sequence$get_values(NULL), 1:10)
  expect_error(sequence_2$get_values(5:15), '*')
  expect_equal(sequence_2$get_values(5:10), 15:20)
})

test_that("getting a set of indices which exist works", {

  vals <- 5:10
  intvar <- IntegerVariable$new(vals)

  set <- 6:8
  indices <- intvar$get_index_of(set = set)  

  expect_equal(indices$to_vector(), 2:4)
})

test_that("getting a set of indices which do not exist works", {

  vals <- 5:10
  intvar <- IntegerVariable$new(vals)

  set <- 1e3:1.001e3
  indices <- intvar$get_index_of(set = set)  

  expect_length(indices$to_vector(), 0)
})

test_that("getting indices within bounds which exist works", {

  vals <- 5:10
  intvar <- IntegerVariable$new(vals)

  a <- 6
  b <- 8
  indices <- intvar$get_index_of(a = a, b = b)  

  expect_equal(indices$to_vector(), 2:4)
})

test_that("getting indices within bounds which do not exist works", {

  vals <- 5:10
  intvar <- IntegerVariable$new(vals)

  a <- 1e3
  b <- 1.001e3
  indices <- intvar$get_index_of(a = a, b = b)  

  expect_length(indices$to_vector(), 0)
})
