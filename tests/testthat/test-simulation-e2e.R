test_that("empty simulation exits gracefully", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  simulation <- simulate(human, list(), 4)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4),
    S_count = c(4, 4, 4, 4),
    I_count = c(0, 0, 0, 0),
    R_count = c(0, 0, 0, 0)
  )
  expect_equal(true_render, simulation$render(human))

  simulation <- simulate(human, list(), 1)

  true_render <- data.frame(
    timestep = c(1),
    S_count = c(4),
    I_count = c(0),
    R_count = c(0)
  )

  expect_equal(true_render, simulation$render(human))

  expect_error(
    simulate(human, list(), 0),
    '*'
  )
})

test_that("deterministic state model works", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

  shift_generator <- function(from, to, rate) {
    return(function(frame, timestep, parameters) {
      from_state <- frame$get_state(human, from)
      StateUpdate$new(
        human,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  processes <- list(
    shift_generator(S, I, 2),
    shift_generator(I, R, 1)
  )

  simulation <- simulate(human, processes, 5)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    S_count = c(4, 2, 0, 0, 0),
    I_count = c(0, 2, 3, 2, 1),
    R_count = c(0, 0, 1, 2, 3)
  )
  rendered <- simulation$render(human)
  expect_mapequal(
    true_render,
    rendered
  )
})

test_that("deterministic state & variable model works", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  value <- Variable$new('value', function(size) rep(1, size))
  human <- Individual$new('human', list(S, I, R), list(value))

  shift_generator <- function(from, to, rate) {
    return(function(frame, timestep, parameters) {
      from_state <- frame$get_state(human, from)
      StateUpdate$new(
        human,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  doubler <- function(frame, timestep, parameters) {
    VariableUpdate$new(
      human,
      value,
      frame$get_variable(human, value) * 2
    )
  }

  processes <- list(
    shift_generator(S, I, 2),
    shift_generator(I, R, 1),
    doubler
  )

  render_mean <- function(individual, variable) {
    function(frame) {
      mean(frame$get_variable(individual, variable))
    }
  }

  simulation <- simulate(
    human,
    processes,
    5,
    renderers=list(value_mean=render_mean(human, sequence))
  )

  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    S_count = c(4, 2, 0, 0, 0),
    I_count = c(0, 2, 3, 2, 1),
    R_count = c(0, 0, 1, 2, 3),
    value_mean = c(1, 2, 4, 8, 16)
  )

  rendered <- simulation$render(human)
  expect_mapequal(true_render, rendered)
})
