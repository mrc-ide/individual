SIR <- c('S', 'I', 'R')

test_that("Creating CategoricalVariables errors with bad input", {
  expect_error(CategoricalVariable$new(NULL, NULL))
  expect_error(CategoricalVariable$new(NaN, NaN))
  expect_error(CategoricalVariable$new(NA, NA))
  expect_error(CategoricalVariable$new(categories = LETTERS[1:2], initial_values = letters[1:2]))
  expect_error(CategoricalVariable$new(categories = character(0), initial_values = letters[1:2]))
})

test_that("CategoricalVariable get index works returns correct values", {
  size <- 10
  state <- CategoricalVariable$new(SIR, rep('S', size))
  expect_setequal(state$get_index_of('S')$to_vector(), seq(10))
  
  state <- CategoricalVariable$new(
    SIR,
    c(rep('S', 10), rep('I', 100), rep('R', 20))
  )
  
  expect_setequal(
    state$get_index_of('S')$to_vector(),
    seq(10)
  )
  
  expect_setequal(
    state$get_index_of(c('S', 'R'))$to_vector(),
    c(seq(10), seq(20) + 110)
  )
  
  expect_setequal(
    state$get_index_of(c('S'))$to_vector(),
    seq(10)
  )
  
})

test_that("CategoricalVariable get index errors with incorrect input", {
  size <- 10
  state <- CategoricalVariable$new(SIR, rep('S', size))
  
  expect_error(state$get_index_of(values = 'A'))
  expect_error(state$get_index_of(values = c('S', 'A')))
  expect_error(state$get_index_of(values = LETTERS[1:3]))
  expect_error(state$get_index_of(values = integer(0)))
  expect_error(state$get_index_of(values = NULL))
  expect_error(state$get_index_of(values = NA))
  expect_error(state$get_index_of(values = NaN))
})

test_that("CategoricalVariable get size of categories works returns correct values", {
  size <- 10
  state <- CategoricalVariable$new(SIR, rep('S', size))
  expect_setequal(state$get_size_of('S'), size)
  
  state <- CategoricalVariable$new(
    SIR,
    c(rep('S', 10), rep('I', 100), rep('R', 20))
  )
  
  expect_equal(state$get_size_of(c('S', 'R')), 30)
  expect_equal(state$get_size_of(c('S', 'I')), 110)
  expect_equal(state$get_size_of(c('S')), 10)
  
})

test_that("CategoricalVariable get size of categories errors with incorrect input", {
  size <- 10
  state <- CategoricalVariable$new(SIR, rep('S', size))
  
  expect_error(state$get_size_of(values = 'A'))
  expect_error(state$get_size_of(values = c('S', 'A')))
  expect_error(state$get_size_of(values = LETTERS[1:3]))
  expect_error(state$get_size_of(values = integer(0)))
  expect_error(state$get_size_of(values = NULL))
  expect_error(state$get_size_of(values = NA))
  expect_error(state$get_size_of(values = NaN))
})

test_that("CategoricalVariables get categories works", {
  size <- 10
  state <- CategoricalVariable$new(SIR, rep('S', size))
  expect_length(setdiff(state$get_categories(), SIR), 0)
})