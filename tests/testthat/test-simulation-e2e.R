test_that("empty simulation exits gracefully", {
  simulation_loop(timesteps = 4)
  expect_true(TRUE) # no errors
})

test_that("deterministic state model works", {
  population <- 4
  timesteps <- 5
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  render <- Render$new(timesteps)

  shift_generator <- function(from, to, rate) {
    function(t) {
      from_state <- state$get_index_of(from)$to_vector()
      state$queue_update(
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    }
  }

  processes <- list(
    shift_generator('S', 'I', 2),
    shift_generator('I', 'R', 1),
    categorical_count_renderer_process(render, state, c('S', 'I', 'R'))
  )

  simulation_loop(
    variables = list(state),
    processes = processes,
    timesteps = 5
  )

  expected <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    S_count = c(4, 2, 0, 0, 0),
    I_count = c(0, 2, 3, 2, 1),
    R_count = c(0, 0, 1, 2, 3)
  )

  expect_mapequal(
    render$to_dataframe(),
    expected
  )
})

test_that("deterministic state model w events works", {
  population <- 4
  timesteps <- 6
  render <- Render$new(timesteps)
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  infection <- TargetedEvent$new(population)
  recovery <- TargetedEvent$new(population)
  infection_delay <- 1
  recovery_delay <- 2

  infection$add_listener(function(simulation, target) {
    state$queue_update('I', target)
  })

  recovery$add_listener(function(simulation, target) {
    state$queue_update('R', target)
  })

  delayed_shift_generator <- function(from, to, event, delay, rate) {
    function(t) {
      from_state <- state$get_index_of(from)
      # remove the already scheduled individuals
      from_state$and(event$get_scheduled()$not())
      target <- from_state$to_vector()[seq_len(min(rate,from_state$size()))]
      event$schedule(target, delay);
    }
  }

  processes <- list(
    delayed_shift_generator('S', 'I', infection, infection_delay, 2),
    delayed_shift_generator('I', 'R', recovery, recovery_delay, 1),
    categorical_count_renderer_process(render, state, c('S', 'I', 'R'))
  )

  simulation_loop(
    variables = list(state),
    events = list(infection, recovery),
    processes = processes,
    timesteps = timesteps
  )

  expected_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5, 6),
    S_count = c(4, 4, 2, 0, 0, 0),
    I_count = c(0, 0, 2, 4, 4, 3),
    R_count = c(0, 0, 0, 0, 0, 1)
  )

  expect_mapequal(render$to_dataframe(), expected_render)
})

test_that("deterministic state & variable model works", {
  population <- 4
  timesteps <- 5
  render <- Render$new(timesteps)
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  value <- DoubleVariable$new(rep(1, population))

  shift_generator <- function(from, to, rate) {
    function(t) {
      from_state <- state$get_index_of(from)
      state$queue_update(
        to,
        from_state$to_vector()[seq_len(min(rate,from_state$size()))]
      )
    }
  }

  doubler <- function(t) value$queue_update(value$get_values() * 2)

  processes <- list(
    shift_generator('S', 'I', 2),
    shift_generator('I', 'R', 1),
    doubler,
    categorical_count_renderer_process(render, state, c('S', 'I', 'R')),
    function(t) render$render('sequence', mean(value$get_values()), t)
  )

  simulation_loop(
    variables = list(state, value),
    processes = processes,
    timesteps = timesteps
  )

  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    S_count = c(4, 2, 0, 0, 0),
    I_count = c(0, 2, 3, 2, 1),
    R_count = c(0, 0, 1, 2, 3),
    sequence= c(1, 2, 4, 8, 16)
  )

  expect_mapequal(true_render, render$to_dataframe())
})
