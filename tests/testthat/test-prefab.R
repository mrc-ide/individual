test_that("fixed_probability_state_change moves a sane number of individuals around", {
  S <- State$new('S', 10)
  I <- State$new('I', 1)
  human <- Individual$new('test', list(S, I))
  state <- create_state(list(human))
  scheduler <- new.env()
  renderer <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), renderer)
  execute_process(
    fixed_probability_state_change_process(
      'test',
      'S',
      'I',
      .5
    ),
    cpp_api
  )
  r_api <- SimAPI$new(cpp_api, scheduler, list(), renderer)
  state_apply_updates(state)
  n_s <- length(r_api$get_state(human, S))
  n_i <- length(r_api$get_state(human, I))
  expect_lte(n_s, 10)
  expect_gte(n_i, 1)
  expect_equal(n_s + n_i, 11)
})

test_that("update_state_listener updates the state correctly", {
  S <- State$new('S', 10)
  I <- State$new('I', 1)
  human <- Individual$new('test', list(S, I))
  state <- create_state(list(human))
  scheduler <- new.env()
  renderer <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), renderer)
  execute_listener(
    update_state_listener('test', 'I'),
    cpp_api,
    c(2, 5)
  )
  r_api <- SimAPI$new(cpp_api, scheduler, list(), renderer)
  state_apply_updates(state)
  expect_setequal(r_api$get_state(human, S), c(1, 3:4, 6:10))
  expect_setequal(r_api$get_state(human, I), c(11, 2, 5))
})

test_that("reschedule_listener schedules the correct update", {
  event <- Event$new('event')
  followup <- Event$new('followup')
  event$add_listener(reschedule_listener('followup', 1))
  event_listener <- mockery::mock()
  event$add_listener(event_listener)
  followup_listener <- mockery::mock()
  followup$add_listener(followup_listener)
  scheduler <- Scheduler$new(list(event, followup), 5)
  renderer <- new.env()
  state <- create_state(list())
  cpp_api <- create_process_api(state, scheduler, list(), renderer)
  r_api <- SimAPI$new(cpp_api, scheduler, list(), renderer)
  #time = 0
  scheduler$schedule(event, c(2, 4), 2)

  #time = 1
  scheduler$process_events(r_api, cpp_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  scheduler$tick()

  #time = 2
  scheduler$process_events(r_api, cpp_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  scheduler$tick()

  #time = 3
  scheduler$process_events(r_api, cpp_api)
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 1)
  scheduler$tick()

  #time = 4
  scheduler$process_events(r_api, cpp_api)
  mockery::expect_called(followup_listener, 1)
  mockery::expect_called(event_listener, 1)
  mockery::expect_args(event_listener, 1, api = r_api, target = c(2, 4))
  args <- mockery::mock_args(followup_listener)
  expect_equal(length(args), 1)
  expect_equal(args[[1]][[1]], r_api)
  expect_setequal(args[[1]][[2]], c(2, 4))
})
