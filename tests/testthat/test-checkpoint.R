test_that("deterministic state model is resumable", {
  simulation <- function(timesteps, state=NULL) {
    population <- 10
    health <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
    render <- Render$new(timesteps)

    shift_generator <- function(from, to, rate) {
      function(t) {
        from_health <- health$get_index_of(from)$to_vector()
        health$queue_update(
          to,
          from_health[seq_len(min(rate,length(from_health)))]
        )
      }
    }

    processes <- list(
      shift_generator('S', 'I', 2),
      shift_generator('I', 'R', 1),
      categorical_count_renderer_process(render, health, c('S', 'I', 'R'))
    )

    new_state <- simulation_loop(
      variables = list(health),
      processes = processes,
      timesteps = timesteps,
      state = state
    )
    list(state=new_state, data=render$to_dataframe())
  }

  first_phase <- simulation(5, state=NULL)
  second_phase <- simulation(10, state=first_phase$state)

  expected <- data.frame(
    timestep = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    S_count = c(10, 8, 6, 4, 2, 0, 0, 0, 0, 0),
    I_count = c(0, 2, 3, 4, 5, 6, 5, 4, 3, 2),
    R_count = c(0, 0, 1, 2, 3, 4, 5, 6, 7, 8)
  )
  expected_na <- data.frame(timestep=1:5, S_count=NA_real_, I_count=NA_real_, R_count=NA_real_)

  expect_mapequal(first_phase$data, expected[1:5,])
  expect_mapequal(second_phase$data[1:5,], expected_na)
  expect_mapequal(second_phase$data[6:10,], expected[6:10,])
})

test_that("stochastic simulation is repeatable", {
  simulation <- function(timesteps, state = NULL) {
    render <- Render$new(timesteps)
    p <- function(t) {
      render$render("value", runif(1), t)
    }
    new_state <- simulation_loop(
      processes = list(p),
      timesteps = timesteps,
      state = state
    )
    list(state=new_state, data=render$to_dataframe())
  }

  initial <- simulation(5)$state
  first <- simulation(10, state=initial)$data
  second <- simulation(10, state=initial)$data

  expect_equal(first, second)
})

test_that("events are not resumable", {
  simulation <- function(timesteps, state = NULL) {
    event <- Event$new()
    simulation_loop(
      events = list(event),
      timesteps = timesteps,
      state = state
    )
  }

  initial <- simulation(5)
  expect_error(simulation(10, state=initial), "Events cannot be restored yet")
})

test_that("cannot add nor remove variables when resuming", {
  make_variables <- function(count) {
    lapply(seq_len(count), function(i) DoubleVariable$new(1:10))
  }

  state <- simulation_loop(timesteps=5, variables=make_variables(2))

  expect_error(
    simulation_loop(timesteps=10, variables=make_variables(1), state=state),
    "Checkpoint's variables do not match simulation's")
  expect_error(
    simulation_loop(timesteps=10, variables=make_variables(3), state=state),
    "Checkpoint's variables do not match simulation's")
})

test_that("cannot resume with smaller timesteps", {
  state <- simulation_loop(timesteps = 10)

  expect_error(
    simulation_loop(timesteps=5, state=state),
    "Restored state is already longer than timesteps")

  expect_error(
    simulation_loop(timesteps=10, state=state),
    "Restored state is already longer than timesteps")
})
