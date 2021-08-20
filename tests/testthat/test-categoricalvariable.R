test_that("getting the state works", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_setequal(state$get_index_of('S')$to_vector(), seq(10))
})

test_that("stores categories", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_length(setdiff(state$get_categories(), c('S', 'I', 'R')), 0)
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
  
  expect_equal(state$get_size_of(c('S', 'I')), 110)
  
  expect_setequal(
    state$get_index_of(c('S'))$to_vector(),
    seq(10)
  )
  
  expect_equal(state$get_size_of(c('S')), 10)
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
  expect_error(
    state$get_index_of(c('R', 'S')),
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

test_that("Queuing invalid indices errors", {
  c <- CategoricalVariable$new(categories = c("A","B"),initial_values = rep(c("A","B"),each=10))
  expect_error(c$queue_update(value = "A",index = c(15,25,50)))
})