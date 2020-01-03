test_that("getting a state index works", {
  S <- State$new('S', 10)
  human <- Individual$new('test', S)
  frame <- SimFrame$new(human, array(rep('S', 10), c(10, 1)))

  expect_identical(frame$get_state(human, S), 1:10)

  I <- State$new('I', 100)
  human <- Individual$new('test', S, I)
  frame <- SimFrame$new(human, array(c(rep('S', 10), rep('I', 100)), c(110, 1)))

  expect_identical(frame$get_state(human, I), 11:110)
})

test_that("getting a non registered state index fails", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', S, I)

  frame <- SimFrame$new(human, array(c(rep('S', 10), rep('I', 100)), c(110, 1)))

  expect_error(
    frame$get_state(human, R),
    '*'
  )
})

test_that("Simulation can correctly initialise", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', S, I, R)

  simulation <- Simulation$new(list(human), 1)
  rendered <- simulation$render(human)
  true_render <- array(c(rep('S', 10), rep('I', 100)), c(110, 1, 1))
  expect_identical(true_render, rendered)
})

test_that("Simulation state updates work", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', S, I)
  simulation <- Simulation$new(list(human), 2)
  updates = list(StateUpdate$new(human, c(1, 3), I))
  frame <- simulation$apply_updates(updates)
  expect_equal(frame$get_state(human, I), c(1, 3))
  expect_equal(frame$get_state(human, S), c(2, 4:10))
})
