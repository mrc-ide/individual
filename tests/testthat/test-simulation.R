
mock_simframe <- function(dataframe) {
  list(
    get_frame = function(individual) dataframe
  )
}

test_that("getting a state index works", {
  S <- State$new('S', 10)
  human <- Individual$new('test', S)

  frame <- SimFrame$new(human)

  expect_identical(frame$get_state(human, S), 1:10)

  I <- State$new('I', 100)
  human <- Individual$new('test', S, I)

  frame <- SimFrame$new(human)

  i <- frame$get_state(human, I)
  expect_length(i, 100)
})

test_that("getting a non registered state index fails", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', S, I)

  frame <- SimFrame$new(human)

  expect_error(
    frame$get_state(human, R),
    '*'
  )
})

test_that("Simulation can store and render two simulation frames", {
  levels <- c('S', 'I')
  simulation <- Simulation$new()
  simulation$add_frame(
    mock_simframe(data.frame(state = factor(rep('S', 4), levels = levels))),
    0
  )
  simulation$add_frame(
    mock_simframe(data.frame(state = factor(rep('I', 4), levels = levels))),
    1
  )
  rendered <- simulation$render(Individual$new('human'))
  true_df <- data.frame(
    timestep=c(rep(0, 4), rep(1, 4)),
    state=factor(c(rep('S', 4), rep('I', 4)), levels = levels)
  )
  expect_mapequal(true_df, rendered)
})

test_that("Simulation state updates work", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', S, I)
  frame <- SimFrame$new(human)
  updates = list(StateUpdate$new(human, c(1, 3), I))
  frame$apply_updates(updates)
  expect_equal(frame$get_state(human, I), c(1, 3))
  expect_equal(frame$get_state(human, S), c(2, 4:10))
})
