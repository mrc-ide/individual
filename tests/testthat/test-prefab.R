test_that("fixed_probability_state_change moves a sane number of individuals around", {
  S <- State$new('S', 10)
  I <- State$new('I', 1)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human))
  execute_process(
    fixed_probability_state_change_process(
      'test',
      'S',
      'I',
      .5
    ),
    sim$cpp_api
  )
  state_apply_updates(sim$state)
  n_s <- length(sim$r_api$get_state(human, S)$to_vector())
  n_i <- length(sim$r_api$get_state(human, I)$to_vector())
  expect_lte(n_s, 10)
  expect_gte(n_i, 1)
  expect_equal(n_s + n_i, 11)
})

test_that("fixed_probability_forked_state_change_process works properly", {
  n <- 1e5
  Source <- State$new('Source', n)
  Dest1 <- State$new('Dest1', 0)
  Dest2 <- State$new('Dest2', 0)
  Dest3 <- State$new('Dest3', 0)
  Dest4 <- State$new('Dest4', 0)
  Dest5 <- State$new('Dest5', 0)
  human <- Individual$new('human', list(Source, Dest1, Dest2, Dest3, Dest4, Dest5))
  sim <- setup_simulation(list(human))

  rate <- 0.9
  probs <- c(0.5,0.3,0.1,0.08,0.02)

  execute_process(
    fixed_probability_forked_state_change_process(
      'human',
      'Source',
      paste0("Dest",1:5),
      rate,
      probs
    ),
    sim$cpp_api
  )
  state_apply_updates(sim$state)

  states <- c(
    sim$r_api$get_state_size(human, Source),
    sim$r_api$get_state_size(human, Dest1),
    sim$r_api$get_state_size(human, Dest2),
    sim$r_api$get_state_size(human, Dest3),
    sim$r_api$get_state_size(human, Dest4),
    sim$r_api$get_state_size(human, Dest5)
  )

  states_expected <- c(
    n*(1-rate),
    n*rate*probs[1],
    n*rate*probs[2],
    n*rate*probs[3],
    n*rate*probs[4],
    n*rate*probs[5]
  )
  states_expected <- as.integer(states_expected)

  ks <- ks.test(states,states_expected)
  expect_gt(ks$p.value,0.98)
})


test_that("update_state_listener updates the state correctly", {
  S <- State$new('S', 10)
  I <- State$new('I', 1)
  event <- Event$new('event')
  event$add_listener(update_state_listener('test', 'I'))
  human <- Individual$new('test', list(S, I), events=list(event))
  sim <- setup_simulation(list(human))
  sim$r_api$schedule(event, c(2, 5), 1)
  scheduler_tick(sim$scheduler)
  scheduler_process_events(sim$scheduler, sim$cpp_api, sim$r_api)
  state_apply_updates(sim$state)
  expect_setequal(sim$r_api$get_state(human, S)$to_vector(), c(1, 3:4, 6:10))
  expect_setequal(sim$r_api$get_state(human, I)$to_vector(), c(11, 2, 5))
})

test_that("reschedule_listener schedules the correct update", {
  event <- Event$new('event')
  followup <- Event$new('followup')
  S <- State$new('S', 10)
  human <- Individual$new('test', list(S), events=list(event, followup))
  event$add_listener(reschedule_listener('followup', 1))
  event_listener <- mockery::mock()
  event$add_listener(event_listener)
  followup_listener <- mockery::mock()
  followup$add_listener(followup_listener)
  sim <- setup_simulation(list(human))
  scheduler <- sim$scheduler
  #time = 0
  sim$r_api$schedule(event, c(2, 4), 2)

  #time = 1
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  scheduler_tick(scheduler)

  #time = 2
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  scheduler_tick(scheduler)

  #time = 3
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 1)
  scheduler_tick(scheduler)

  #time = 4
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(followup_listener, 1)
  mockery::expect_called(event_listener, 1)
  mockery::expect_args(event_listener, 1, api = sim$r_api, target = c(2, 4))
  args <- mockery::mock_args(followup_listener)
  expect_equal(length(args), 1)
  expect_equal(args[[1]][[1]], sim$r_api)
  expect_setequal(args[[1]][[2]], c(2, 4))
})
