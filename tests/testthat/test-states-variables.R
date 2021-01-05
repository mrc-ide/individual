test_that("getting the state works", {
  S <- State$new('S', 10)
  human <- Individual$new('test', list(S))
  sim <- setup_simulation(list(human))
  expect_setequal(sim$r_api$get_state(human, list(S))$to_vector(), seq(10))

  I <- State$new('I', 100)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human))

  expect_setequal(sim$r_api$get_state(human, list(I))$to_vector(), seq(100) + 10)
})

test_that("Getting multiple states works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 20)
  human <- Individual$new('test', list(S, I, R))

  sim <- setup_simulation(list(human))
  expect_setequal(sim$r_api$get_state(human, list(S, R))$to_vector(), c(seq(10), seq(20) + 110))
})

test_that("getting a non registered state index fails", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I))

  sim <- setup_simulation(list(human))

  expect_error(
    sim$r_api$get_state(human, list(R)),
    '*'
  )
})

test_that("getting variables works", {
  size <- 10
  S <- State$new('S', size)
  sequence <- Variable$new('sequence', seq_len(size))
  sequence_2 <- Variable$new('sequence 2', seq_len(size) + 10)
  human <- Individual$new('test', list(S), variables=list(sequence, sequence_2))

  sim <- setup_simulation(list(human))

  expect_equal(sim$r_api$get_variable(human, sequence), 1:10)
  expect_equal(sim$r_api$get_variable(human, sequence_2), (1:10) + 10)
})

test_that("getting variables at an index works", {
  size <- 10
  S <- State$new('S', size)
  sequence <- Variable$new('sequence', seq_len(size))
  sequence_2 <- Variable$new('sequence 2', seq_len(size) + 10)
  human <- Individual$new('test', list(S), variables=list(sequence, sequence_2))

  sim <- setup_simulation(list(human))

  expect_equal(sim$r_api$get_variable(human, sequence, NULL), 1:10)
  expect_error(sim$r_api$get_variable(human, sequence_2, 5:15), '*')
  expect_equal(sim$r_api$get_variable(human, sequence_2, 5:10), 15:20)
})
