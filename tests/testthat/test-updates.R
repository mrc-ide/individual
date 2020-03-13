test_that("updating variables works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 3)
  first <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, (1:5) * 2, 1:5))
  )
  middle <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11, 2:6))
  )
  last <- simulation$get_current_frame()$get_variable(human, sequence)

  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
})

test_that("updating variables at the boundaries works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 3)
  before <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 2, 10))
  )
  after <- simulation$get_current_frame()$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, c(1:9, 2))
})

test_that("updating variables tolerates empty fills", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 2)
  before <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11, numeric(0)))
  )
  after <- simulation$get_current_frame()$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, 1:10)
})

test_that("updating past the last timestep errors gracefully", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))
  simulation <- Simulation$new(list(human), 2)

  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11, 2:6))
  )

  expect_error(
    simulation$apply_updates(
      list(VariableUpdate$new(human, sequence, 11, 2:6))
    ),
    '*'
  )
})

test_that("updating variables with silly indecies errors gracefully", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 2)

  expect_error(
    simulation$apply_updates(
      list(VariableUpdate$new(human, sequence, c(1.0, 2.0), 1:5))
    ),
    '*'
  )

  simulation <- Simulation$new(list(human), 2)

  expect_error(
    simulation$apply_updates(
      list(VariableUpdate$new(human, sequence, 11, -1:3))
    ),
    '*'
  )

  simulation <- Simulation$new(list(human), 2)

  expect_error(
    simulation$apply_updates(
      list(VariableUpdate$new(human, sequence, 11, 9:15))
    ),
    '*'
  )
})

test_that("updating the complete variable vector works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 2)
  before <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 11:20))
  )
  after <- simulation$get_current_frame()$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, 11:20)
})

test_that("Vector fill variable updates work", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  simulation <- Simulation$new(list(human), 2)
  before <- simulation$get_current_frame()$get_variable(human, sequence)
  simulation$apply_updates(
    list(VariableUpdate$new(human, sequence, 14))
  )
  after <- simulation$get_current_frame()$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, rep(14, 10))
})

test_that("Simulation state updates work", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  simulation <- Simulation$new(list(human), 2)
  updates = list(StateUpdate$new(human, I, c(1, 3)))
  simulation$apply_updates(updates)
  frame <- simulation$get_current_frame()
  expect_setequal(frame$get_state(human, I), c(1, 3))
  expect_setequal(frame$get_state(human, S), c(2, 4:10))
})

test_that("Simulation state updates work after null updates", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  simulation <- Simulation$new(list(human), 3)
  simulation$apply_updates(list(StateUpdate$new(human, I, numeric(0))))
  frame <- simulation$get_current_frame()
  expect_setequal(frame$get_state(human, I), numeric(0))
  expect_setequal(frame$get_state(human, S), c(1:10))
  simulation$apply_updates(list(StateUpdate$new(human, I, c(1, 3))))
  frame <- simulation$get_current_frame()
  expect_setequal(frame$get_state(human, I), c(1, 3))
  expect_setequal(frame$get_state(human, S), c(2, 4:10))
})


test_that("Simulation state updates work with duplicate elements", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  simulation <- Simulation$new(list(human), 3)
  updates = list(StateUpdate$new(human, I, c(1, 1, 3, 3)))
  simulation$apply_updates(updates)
  frame <- simulation$get_current_frame()
  expect_setequal(frame$get_state(human, I), c(1, 3))
  expect_setequal(frame$get_state(human, S), c(2, 4:10))
  simulation$apply_updates(updates)
  frame <- simulation$get_current_frame()
  expect_setequal(frame$get_state(human, I), c(1, 3))
  expect_setequal(frame$get_state(human, S), c(2, 4:10))
})
