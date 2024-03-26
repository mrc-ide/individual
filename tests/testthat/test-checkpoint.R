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

test_that("can add named variables when resuming", {
  state <- simulation_loop(timesteps = 5, variables = list(
    a = DoubleVariable$new(1:10)
  ))
  expect_no_error(simulation_loop(timesteps = 10, state = state, variables = list(
    a = DoubleVariable$new(1:10),
    b = DoubleVariable$new(1:10)
  )))
})

test_that("cannot add unnamed variables when resuming", {
  state <- simulation_loop(timesteps = 5, variables = list(
    DoubleVariable$new(1:10)
  ))
  expect_error(simulation_loop(timesteps = 10, state = state, variables = list(
    DoubleVariable$new(1:10),
    DoubleVariable$new(1:10)
  )), "Saved state does not match resumed objects")
})

test_that("cannot remove variables when resuming", {
  state <- simulation_loop(timesteps = 5, variables = list(
    a = DoubleVariable$new(1:10),
    b = DoubleVariable$new(1:10)
  ))
  expect_error(simulation_loop(timesteps = 10, state = state, variables = list(
    a = DoubleVariable$new(1:10)
  )), "Saved state contains more objects than expected: b")
})

test_that("can add events when resuming", {
  state <- simulation_loop(timesteps = 5, events = list())

  listener <- mockery::mock()
  event <- Event$new()
  event$schedule(7)
  event$add_listener(listener)
  simulation_loop(timesteps = 10, events = list(a=event))

  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, t = 8)
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

MockState <- R6Class(
  'MockState',
  private = list(value = NULL),
  public = list(
    save_state = function() private$value,
    restore_state = NULL,
    initialize = function(value = NULL) {
      private$value <- value
      self$restore_state <- mockery::mock()
    }
  )
)

test_that("saved object's state is returned", {
  o <- MockState$new("foo")
  state <- save_object_state(o)
  expect_identical(state, "foo")
})

test_that("saved objects' state is returned as list", {
  o1 <- MockState$new("foo")
  o2 <- MockState$new("bar")
  state <- save_object_state(list(o1, o2))
  expect_identical(state, list("foo", "bar"))
})

test_that("saved objects' state preserves names", {
  o1 <- MockState$new("foo")
  o2 <- MockState$new("bar")
  state <- save_object_state(list(x=o1, y=o2))
  expect_identical(state, list(x="foo", y="bar"))
})

test_that("saved objects' state preserves nested structure", {
  o1 <- MockState$new("foo")
  o2 <- MockState$new("bar")
  o3 <- MockState$new("baz")

  state <- save_object_state(list(x=o1, y=list(o2, o3)))
  expect_identical(state, list(x="foo", y=list("bar", "baz")))
})

test_that("empty list is returned for empty list of objects", {
  state <- save_object_state(list())
  expect_identical(state, list())
})

test_that("restore_state method is called on object", {
  o <- MockState$new()
  restore_object_state(123, o, "state")
  mockery::expect_called(o$restore_state, 1)
  mockery::expect_args(o$restore_state, 1, 123, "state")
})

test_that("restore_state method is called on object list", {
  o1 <- MockState$new()
  o2 <- MockState$new()
  restore_object_state(123, list(o1, o2), list("hello", "world"))

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, "hello")

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, "world")
})

test_that("restore_state method is called on named object list", {
  o1 <- MockState$new()
  o2 <- MockState$new()

  # Lists get paired up by name, even if the order is different
  restore_object_state(123, list(x=o1, y=o2), list(y="world", x="hello"))

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, "hello")

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, "world")
})

test_that("restore_state method is called on nested object list", {
  o1 <- MockState$new()
  o2 <- MockState$new()
  o3 <- MockState$new()

  restore_object_state(
    123,
    list(list(o1, o2), o3),
    list(list("foo", "bar"), "baz"))

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, "foo")

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, "bar")

  mockery::expect_called(o3$restore_state, 1)
  mockery::expect_args(o3$restore_state, 1, 123, "baz")
})

test_that("restore_state method is called with NULL for new objects", {
  o1 <- MockState$new()
  o2 <- MockState$new()
  o3 <- MockState$new()

  restore_object_state(
    123,
    list(x=o1, y=o2, z=o3),
    list(x="foo", z="baz"))

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, "foo")

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, NULL)

  mockery::expect_called(o3$restore_state, 1)
  mockery::expect_args(o3$restore_state, 1, 123, "baz")
})

test_that("cannot restore objects with partial unnamed list", {
  o1 <- MockState$new()
  o2 <- MockState$new()

  expect_error(
    restore_object_state(123, list(o1, o2), list("foo")),
    "Saved state does not match resumed objects")
})

test_that("restore_state method is called with NULL for new list of objects", {
  o1 <- MockState$new()
  o2 <- MockState$new()
  o3 <- MockState$new()

  restore_object_state(
    123,
    list(x=o1, y=list(o2, o3)),
    list(x="foo"))

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, "foo")

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, NULL)

  mockery::expect_called(o3$restore_state, 1)
  mockery::expect_args(o3$restore_state, 1, 123, NULL)
})

test_that("restore_state method is called with NULL for all objects", {
  o1 <- MockState$new()
  o2 <- MockState$new()
  o3 <- MockState$new()

  restore_object_state(123, list(x=o1, y=o2, z=o3), NULL)

  mockery::expect_called(o1$restore_state, 1)
  mockery::expect_args(o1$restore_state, 1, 123, NULL)

  mockery::expect_called(o2$restore_state, 1)
  mockery::expect_args(o2$restore_state, 1, 123, NULL)

  mockery::expect_called(o3$restore_state, 1)
  mockery::expect_args(o3$restore_state, 1, 123, NULL)
})
