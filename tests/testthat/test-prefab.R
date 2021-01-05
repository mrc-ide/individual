test_that("bernoulli_process moves a sane number of individuals around", {
  state <- CategoricalVariable(c('S', 'I'), c(rep('S', 10), 'I'))
  execute_process(bernoulli_process(state, 'S', 'I', .5), 1)
  state$.update()
  state_apply_updates(sim$state)
  n_s <- length(state$get_index_for('S'))
  n_i <- length(state$get_index_for('I'))
  expect_lte(n_s, 10)
  expect_gte(n_i, 1)
  expect_equal(n_s + n_i, 11)
})

test_that("update_state_listener updates the state correctly", {
  state <- CategoricalVariable(c('S', 'I'), c(rep('S', 10), 'I'))
  event <- Event$new()
  event$add_listener(update_state_listener(state, 'I'))
  event$schedule(c(2, 5), 1)
  event$.tick()
  event$.process()
  state$.update()
  expect_setequal(state$get_index_for('S'), c(1, 3:4, 6:10))
  expect_setequal(state$get_index_for('I'), c(11, 2, 5))
})

test_that("reschedule_listener schedules the correct update", {
  event <- Event$new()
  followup <- Event$new()
  S <- State$new('S', 10)
  event$add_listener(reschedule_listener(followup, 1))
  event_listener <- mockery::mock()
  event$add_listener(event_listener)
  followup_listener <- mockery::mock()
  followup$add_listener(followup_listener)

  #time = 0
  event$schedule(c(2, 4), 2)

  #time = 1
  event$.process()
  followup$.process()
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 2
  event$.process()
  followup$.process()
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 3
  event$.process()
  followup$.process()
  mockery::expect_called(event_listener, 1)
  mockery::expect_called(followup_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 4
  event$.process()
  followup$.process()
  mockery::expect_called(event_listener, 1)
  mockery::expect_called(followup_listener, 1)
  event$.tick()
  followup$.tick()
  mockery::expect_args(event_listener, 1, 4, target = c(2, 4))
  mockery::expect_args(followup_listener, 1, 4, target = c(2, 4))
})
