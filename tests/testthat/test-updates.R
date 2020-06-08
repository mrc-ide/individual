test_that("updating variables works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))
  sim <- setup_simulation(list(human))

  first <- sim$r_api$get_variable(human, sequence)
  sim$r_api$queue_variable_update(human, sequence, (1:5) * 2, 1:5)
  state_apply_updates(sim$state)
  middle <- sim$r_api$get_variable(human, sequence)
  sim$r_api$queue_variable_update(human, sequence, 11, 2:6)
  state_apply_updates(sim$state)
  last <- sim$r_api$get_variable(human, sequence)

  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
})

test_that("updating variables at the boundaries works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  sim <- setup_simulation(list(human))

  before <- sim$r_api$get_variable(human, sequence)
  sim$r_api$queue_variable_update(human, sequence, 2, 10)
  state_apply_updates(sim$state)
  after <- sim$r_api$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, c(1:9, 2))
})

test_that("updating variables with an empty index results in a fill", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  sim <- setup_simulation(list(human))

  before <- sim$r_api$get_variable(human, sequence)
  sim$r_api$queue_variable_update(human, sequence, 11, numeric(0))
  state_apply_updates(sim$state)
  after <- sim$r_api$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, rep(11, 10))
})

test_that("updating variables with silly indecies errors gracefully", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  sim <- setup_simulation(list(human))

  expect_error(
    sim$r_api$queue_variable_update(human, sequence, c(1.0, 2.0), 1:5),
    '*'
  )

  expect_error(
    sim$r_api$queue_variable_update(human, sequence, 11, -1:3),
    '*'
  )

  expect_error(
    sim$r_api$queue_variable_update(human, sequence, 11, 9:15),
    '*'
  )
})

test_that("updating the complete variable vector works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  sim <- setup_simulation(list(human))

  before <- sim$r_api$get_variable(human, sequence)

  sim$r_api$queue_variable_update(human, sequence, 11:20)
  state_apply_updates(sim$state)

  after <- sim$r_api$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, 11:20)
})

test_that("Vector fill variable updates work", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  human <- Individual$new('test', list(S), variables=list(sequence))

  sim <- setup_simulation(list(human))

  before <- sim$r_api$get_variable(human, sequence)
  sim$r_api$queue_variable_update(human, sequence, 14)
  state_apply_updates(sim$state)
  after <- sim$r_api$get_variable(human, sequence)

  expect_equal(before, 1:10)
  expect_equal(after, rep(14, 10))
})

test_that("Simulation state updates work", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human))
  sim$r_api$queue_state_update(human, I, c(1, 3))
  state_apply_updates(sim$state)
  expect_setequal(sim$r_api$get_state(human, list(I)), c(1, 3))
  expect_setequal(sim$r_api$get_state(human, list(S)), c(2, 4:10))
})

test_that("Simulation state updates work after null updates", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human))
  sim$r_api$queue_state_update(human, I, numeric(0))
  state_apply_updates(sim$state)
  expect_setequal(sim$r_api$get_state(human, list(I)), numeric(0))
  expect_setequal(sim$r_api$get_state(human, list(S)), c(1:10))
  sim$r_api$queue_state_update(human, I, c(1, 3))
  state_apply_updates(sim$state)
  expect_setequal(sim$r_api$get_state(human, list(I)), c(1, 3))
  expect_setequal(sim$r_api$get_state(human, list(S)), c(2, 4:10))
})


test_that("Simulation state updates work with duplicate elements", {
  S <- State$new('S', 10)
  I <- State$new('I', 0)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human))
  sim$r_api$queue_state_update(human, I, c(1, 1, 3, 3))
  state_apply_updates(sim$state)
  expect_setequal(sim$r_api$get_state(human, list(I)), c(1, 3))
  expect_setequal(sim$r_api$get_state(human, list(S)), c(2, 4:10))
})