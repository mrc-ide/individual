test_that("getting the state works", {
  S <- State$new('S', 10)
  human <- Individual$new('test', list(S))
  simulation <- Simulation$new(list(human), 1)
  frame <- simulation$get_current_frame()

  expect_length(frame$get_state(human, S), 10)

  I <- State$new('I', 100)
  human <- Individual$new('test', list(S, I))
  simulation <- Simulation$new(list(human), 1)
  frame <- simulation$get_current_frame()

  expect_length(frame$get_state(human, I), 100)
})

test_that("Getting multiple states works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 20)
  human <- Individual$new('test', list(S, I, R))

  simulation <- Simulation$new(list(human), 1)
  frame <- simulation$get_current_frame()
  expect_length(frame$get_state(human, S, R), 30)
})

test_that("getting a non registered state index fails", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I))

  simulation <- Simulation$new(list(human), 1)
  frame <- simulation$get_current_frame()

  expect_error(
    frame$get_state(human, R),
    '*'
  )
})

test_that("getting variables works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  sequence_2 <- Variable$new('sequence 2', function(size) seq_len(size) + 10)
  human <- Individual$new('test', list(S), variables=list(sequence, sequence_2))

  simulation <- Simulation$new(list(human), 1)
  frame <- simulation$get_current_frame()

  expect_equal(frame$get_variable(human, sequence), 1:10)
  expect_equal(frame$get_variable(human, sequence_2), (1:10) + 10)
})

test_that("updating variables works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 3)
  first <- simulation$get_current_frame()
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, (1:5) * 2, 1:5))
  )
  middle <- simulation$get_current_frame()
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11, 2:6))
  )
  last <- simulation$get_current_frame()

  expect_equal(first$get_variable(human, sequence), 1:10)
  expect_equal(middle$get_variable(human, sequence), c((1:5) * 2, 6:10))
  expect_equal(last$get_variable(human, sequence), c(2, rep(11, 5), 7:10))

  # States are unchanged
  expect_equal(first$get_state(human, S), 1:10)
  expect_equal(middle$get_state(human, S), 1:10)
  expect_equal(last$get_state(human, S), 1:10)
})

test_that("updating the complete variable vector works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 2)
  before <- simulation$get_current_frame()
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11:20))
  )
  after <- simulation$get_current_frame()

  expect_equal(before$get_variable(human, sequence), 1:10)
  expect_equal(after$get_variable(human, sequence), 11:20)
})

test_that("Simulation can render one frame", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I, R))

  simulation <- Simulation$new(list(human), 1)
  rendered <- simulation$render(human)
  true_render <- array(c(rep('S', 10), rep('I', 100)), c(110, 1))
  expect_equal(true_render, rendered$states)
})

test_that("Simulation state updates work", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  simulation <- Simulation$new(list(human), 2)
  updates = list(StateUpdate$new(human, I, c(1, 3)))
  frame <- simulation$apply_updates(updates)
  expect_equal(frame$get_state(human, I), c(1, 3))
  expect_equal(frame$get_state(human, S), c(2, 4:10))
})
