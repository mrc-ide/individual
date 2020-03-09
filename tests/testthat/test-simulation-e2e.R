test_that("empty simulation exits gracefully", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  simulation <- simulate(human, list(), 4)
  true_render  <- array(
    rep('S', 20),
    c(4, 4)
  )
  expect_equal(true_render, simulation$render(human)$states)

  simulation <- simulate(human, list(), 1)
  true_render <- array(
    rep('S', 4),
    c(4, 1)
  )
  expect_equal(true_render, simulation$render(human)$states)

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
  true_render <- array(
    c(
      rep('S', 4), #t=1
      rep('S', 2), #t=2
      rep('I', 2),
      rep('I', 3), #t=3
      'R',
      rep('I', 2), #t=4
      rep('R', 2),
      rep('I', 1), #t=5
      rep('R', 3)
    ),
    c(4, 5)
  )
  rendered <- simulation$render(human)$states
  expect_equal(
    sort_simulation_states(true_render),
    sort_simulation_states(rendered)
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

  simulation <- simulate(human, processes, 5)
  true_states <- array(
    c(
      rep('S', 4), #t=1
      rep('S', 2), #t=2
      rep('I', 2),
      rep('I', 3), #t=3
      'R',
      rep('I', 2), #t=4
      rep('R', 2),
      rep('I', 1), #t=5
      rep('R', 3)
    ),
    c(4, 5)
  )

  true_variables <- array(
    c(
      rep(1, 4),
      rep(2, 4),
      rep(4, 4),
      rep(8, 4),
      rep(16, 4)
    ),
    c(4, 5)
  )
  rendered_states <- simulation$render(human)$states
  rendered_value <- simulation$render(human)$variables[,,'value']
  expect_equal(
    sort_simulation_states(true_states),
    sort_simulation_states(rendered_states)
  )
  expect_equal(true_variables, rendered_value)
})
