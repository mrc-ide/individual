test_that("empty simulation exits gracefully", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  render <- simulate(human, list(), 4)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4),
    human_S_count = c(4, 4, 4, 4),
    human_I_count = c(0, 0, 0, 0),
    human_R_count = c(0, 0, 0, 0)
  )
  expect_equal(true_render, render)

  render <- simulate(human, list(), 1)

  true_render <- data.frame(
    timestep = c(1),
    human_S_count = c(4),
    human_I_count = c(0),
    human_R_count = c(0)
  )

  expect_equal(true_render, render)

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

  render <- simulate(human, processes, 5)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 3, 2, 1),
    human_R_count = c(0, 0, 1, 2, 3)
  )
  expect_mapequal(
    true_render,
    render
  )
})

test_that("deterministic state model works w 2 individuals", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  alien <- Individual$new('alien', list(S, I, R))

  shift_generator <- function(individual, from, to, rate) {
    return(function(frame, timestep, parameters) {
      from_state <- frame$get_state(individual, from)
      StateUpdate$new(
        individual,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  processes <- list(
    shift_generator(human, S, I, 2),
    shift_generator(human, I, R, 1),
    shift_generator(alien, S, I, 1),
    shift_generator(alien, I, R, 2)
  )

  render <- simulate(list(human, alien), processes, 5)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 3, 2, 1),
    human_R_count = c(0, 0, 1, 2, 3),
    alien_S_count = c(4, 3, 2, 1, 0),
    alien_I_count = c(0, 1, 1, 1, 1),
    alien_R_count = c(0, 0, 1, 2, 3)
  )
  expect_mapequal(
    true_render,
    render
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

  render <- simulate(
    human,
    processes,
    5,
    custom_renderers=list(function(frame) {
      list(value_mean=mean(frame$get_variable(human, value)))
    })
  )

  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 3, 2, 1),
    human_R_count = c(0, 0, 1, 2, 3),
    value_mean = c(1, 2, 4, 8, 16)
  )

  expect_mapequal(true_render, render)
})
