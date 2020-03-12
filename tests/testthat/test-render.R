test_that("Premature render works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I, R))

  simulation <- Simulation$new(list(human), 2)
  rendered <- simulation$render(human)
  true_render <- data.frame(
    timestep = c(1),
    S_count = c(10),
    I_count = c(100),
    R_count = c(0)
  )
  expect_mapequal(true_render, rendered)
})

test_that("Simulation can render state counts", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I, R))

  simulation <- Simulation$new(list(human), 2)
  updates = list(StateUpdate$new(human, I, c(1, 3)))
  simulation$apply_updates(updates)
  rendered <- simulation$render(human)
  true_render <- data.frame(
    timestep = c(1, 2),
    S_count = c(10, 8),
    I_count = c(100, 102),
    R_count = c(0, 0)
  )
  expect_mapequal(true_render, rendered)
})

test_that("Simulation can render variable summaries", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  sequence_2 <- Variable$new('sequence_2', function(size) seq_len(size) * 10)
  human <- Individual$new('test', list(S, I, R), list(sequence, sequence_2))

  render_mean <- function(individual, variable) {
    function(frame) {
      mean(frame$get_variable(individual, variable))
    }
  }

  simulation <- Simulation$new(
    list(human),
    2,
    renderers=list(
      sequence_mean=render_mean(human, sequence),
      sequence_2_mean=render_mean(human, sequence_2)
    )
  )

  updates = list(
    StateUpdate$new(human, I, c(1, 3)),
    VariableUpdate$new(human, sequence, (1:5) * 2, 1:5)
  )

  simulation$apply_updates(updates)

  rendered <- simulation$render(human)
  true_render <- data.frame(
    timestep = c(1, 2),
    S_count = c(10, 8),
    I_count = c(100, 102),
    R_count = c(0, 0),
    sequence_mean = c(5.5, 7),
    sequence_2_mean = c(55, 55),
  )
  expect_mapequal(true_render, rendered)
})
