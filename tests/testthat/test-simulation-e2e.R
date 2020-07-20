test_that("empty simulation exits gracefully", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  render <- simulate(human, list(), 4)
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4)
  )
  expect_equal(true_render, render)

  render <- simulate(human, list(), 1)

  true_render <- data.frame(timestep = c(1))

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
    return(function(simulation) {
      from_state <- simulation$get_state(human, from)
      simulation$queue_state_update(
        human,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  processes <- list(
    shift_generator(S, I, 2),
    shift_generator(I, R, 1),
    state_count_renderer_process(human$name, c(S$name, I$name, R$name))
  )

  render <- simulate(human, processes, 5)
  expected <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 3, 2, 1),
    human_R_count = c(0, 0, 1, 2, 3)
  )
  expect_mapequal(
    render,
    expected
  )
})

test_that("deterministic state model works w parameters", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

  shift_generator <- function(from, to) {
    return(function(simulation) {
      from_state <- simulation$get_state(human, from)
      rate <- simulation$get_parameters()$rate
      simulation$queue_state_update(
        human,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  processes <- list(
    shift_generator(S, I),
    shift_generator(I, R),
    state_count_renderer_process(human$name, c(S$name, I$name, R$name))
  )

  render <- simulate(human, processes, 5, parameters=list(rate = 2))
  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 2, 0, 0),
    human_R_count = c(0, 0, 2, 4, 4)
  )
  expect_mapequal(
    true_render,
    render
  )
})

test_that("deterministic state model w events works", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  infection <- Event$new('infection')
  recovery <- Event$new('recovery')
  infection_delay <- 1
  recovery_delay <- 2

  human <- Individual$new(
    'human',
    list(S, I, R),
    events=list(infection, recovery)
  )

  infection$add_listener(function(simulation, target) {
    simulation$queue_state_update(human, I, target)
  })

  recovery$add_listener(function(simulation, target) {
    simulation$queue_state_update(human, R, target)
  })

  delayed_shift_generator <- function(from, to, event, delay, rate) {
    return(function(simulation) {
      from_state <- simulation$get_state(human, from)
      # remove the already scheduled individuals
      from_state <- setdiff(from_state, simulation$get_scheduled(event))
      target <- from_state[seq_len(min(rate,length(from_state)))]
      simulation$schedule(event, target, delay);
    })
  }

  processes <- list(
    delayed_shift_generator(S, I, infection, infection_delay, 2),
    delayed_shift_generator(I, R, recovery, recovery_delay, 1),
    state_count_renderer_process(human$name, c(S$name, I$name, R$name))
  )

  render <- simulate(human, processes, 6)
  expected_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5, 6),
    human_S_count = c(4, 4, 2, 0, 0, 0),
    human_I_count = c(0, 0, 2, 4, 4, 3),
    human_R_count = c(0, 0, 0, 0, 0, 1)
  )
  expect_mapequal(
    render,
    expected_render
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
    return(function(simulation) {
      from_state <- simulation$get_state(individual, from)
      simulation$queue_state_update(
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
    shift_generator(alien, I, R, 2),
    state_count_renderer_process(human$name, c(S$name, I$name, R$name)),
    state_count_renderer_process(alien$name, c(S$name, I$name, R$name))
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
    return(function(simulation) {
      from_state <- simulation$get_state(human, from)
      simulation$queue_state_update(
        human,
        to,
        from_state[seq_len(min(rate,length(from_state)))]
      )
    })
  }

  doubler <- function(simulation) {
    simulation$queue_variable_update(
      human,
      value,
      simulation$get_variable(human, value) * 2
    )
  }

  processes <- list(
    shift_generator(S, I, 2),
    shift_generator(I, R, 1),
    doubler,
    state_count_renderer_process(human$name, c(S$name, I$name, R$name)),
    variable_mean_renderer_process(human$name, value$name)
  )

  render <- simulate(human, processes, 5)

  true_render <- data.frame(
    timestep = c(1, 2, 3, 4, 5),
    human_S_count = c(4, 2, 0, 0, 0),
    human_I_count = c(0, 2, 3, 2, 1),
    human_R_count = c(0, 0, 1, 2, 3),
    human_value_mean = c(1, 2, 4, 8, 16)
  )

  expect_mapequal(true_render, render)
})
