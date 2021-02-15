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
