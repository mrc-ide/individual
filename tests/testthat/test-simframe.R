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
