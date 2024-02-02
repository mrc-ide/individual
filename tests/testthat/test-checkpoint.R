test_that("deterministic state model is resumable", {
  simulation <- function(timesteps, ...) {
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
      ...
    )
    list(state = new_state, data = render$to_dataframe())
  }

  first_phase <- simulation(5)
  second_phase <- simulation(10, state = first_phase$state)

  expected <- data.frame(
    timestep = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
    S_count = c(10, 8, 6, 4, 2, 0, 0, 0, 0, 0),
    I_count = c(0, 2, 3, 4, 5, 6, 5, 4, 3, 2),
    R_count = c(0, 0, 1, 2, 3, 4, 5, 6, 7, 8)
  )
  expected_na <- data.frame(
    timestep = 1:5,
    S_count=NA_real_,
    I_count=NA_real_,
    R_count=NA_real_
  )

  expect_mapequal(first_phase$data, expected[1:5,])
  expect_mapequal(second_phase$data[1:5,], expected_na)
  expect_mapequal(second_phase$data[6:10,], expected[6:10,])
})

test_that("deterministic model with events is resumable", {
  simulation <- function(timesteps, ...) {
    population <- 10
    health <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
    render <- Render$new(timesteps)

    infection <- TargetedEvent$new(population)
    recovery <- TargetedEvent$new(population)

    infection$add_listener(function(simulation, target) {
      health$queue_update('I', target)
    })

    recovery$add_listener(function(simulation, target) {
      health$queue_update('R', target)
    })

    delayed_shift_generator <- function(from, event, delay, rate) {
      function(t) {
        from_state <- health$get_index_of(from)
        # remove the already scheduled individuals
        from_state$and(event$get_scheduled()$not(TRUE))
        target <- from_state$to_vector()[seq_len(min(rate,from_state$size()))]
        event$schedule(target, delay);
      }
    }

    processes <- list(
      delayed_shift_generator('S', infection, 1, 2),
      delayed_shift_generator('I', recovery, 2, 1),
      categorical_count_renderer_process(render, health, c('S', 'I', 'R'))
    )

    new_state <- simulation_loop(
      variables = list(health),
      events = list(infection, recovery),
      processes = processes,
      timesteps = timesteps,
      ...
    )
    list(state = new_state, data = render$to_dataframe())
  }

  first_phase <- simulation(5)
  second_phase <- simulation(15, state = first_phase$state)

  expected <- data.frame(
    timestep = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
    S_count = c(10, 10, 8, 6, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    I_count = c(0, 0, 2, 4, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1, 0),
    R_count = c(0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  )
  expected_na <- data.frame(
    timestep = 1:5,
    S_count=NA_real_,
    I_count=NA_real_,
    R_count=NA_real_
  )

  expect_mapequal(first_phase$data, expected[1:5,])
  expect_mapequal(second_phase$data[1:5,], expected_na)
  expect_mapequal(second_phase$data[6:15,], expected[6:15,])
})

stochastic_model <- function(timesteps, ...) {
  render <- Render$new(timesteps)
  p <- function(t) {
    render$render("value", runif(1), t)
  }
  new_state <- simulation_loop(
    processes = list(p),
    timesteps = timesteps,
    ...
  )
  list(state = new_state, data = render$to_dataframe())
}

test_that("stochastic simulations are resumed independently by default", {
  initial_state <- stochastic_model(5)$state
  first_run <- stochastic_model(10, state = initial_state)$data
  second_run <- stochastic_model(10, state = initial_state)$data

  expect_false(isTRUE(all.equal(first_run, second_run)))
})

test_that("stochastic simulation can be resumed deterministically", {
  set.seed(123)
  initial <- stochastic_model(5)
  first_run <- stochastic_model(
    10, state = initial$state, restore_random_state = TRUE)$data
  second_run <- stochastic_model(
    10, state = initial$state, restore_random_state = TRUE)$data

  expect_mapequal(first_run, second_run)

  set.seed(123)
  contiguous_run <- stochastic_model(10)$data

  expect_mapequal(contiguous_run[1:5,], initial$data)
  expect_mapequal(contiguous_run[6:10,], first_run[6:10,])
  expect_mapequal(contiguous_run[6:10,], second_run[6:10,])
})

test_that("cannot add nor remove variables when resuming", {
  make_variables <- function(count) {
    lapply(seq_len(count), function(i) DoubleVariable$new(1:10))
  }

  state <- simulation_loop(timesteps = 5, variables = make_variables(2))

  expect_error(
    simulation_loop(timesteps = 10, variables = make_variables(1), state = state),
    "Checkpoint's variables do not match simulation's")
  expect_error(
    simulation_loop(timesteps = 10, variables = make_variables(3), state = state),
    "Checkpoint's variables do not match simulation's")
})

test_that("cannot resume with smaller timesteps", {
  state <- simulation_loop(timesteps = 10)

  expect_error(
    simulation_loop(timesteps = 5, state = state),
    "Restored state is already longer than timesteps")

  expect_error(
    simulation_loop(timesteps = 10, state = state),
    "Restored state is already longer than timesteps")
})
