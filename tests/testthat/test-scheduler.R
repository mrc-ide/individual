test_that("events can be scheduled for the future", {
  event <- Event$new('event')
  listener <- mockery::mock()
  api <- mockery::mock()
  event$add_listener(listener)
  scheduler <- Scheduler$new(5)
  #time = 0
  scheduler$schedule(event, c(2, 4), 2)

  #time = 1
  scheduler$process_events(api)
  mockery::expect_called(listener, 0)
  scheduler$tick()

  #time = 2
  scheduler$process_events(api)
  mockery::expect_called(listener, 0)
  scheduler$tick()

  #time = 3
  scheduler$process_events(api)
  mockery::expect_called(listener, 1)
  scheduler$tick()

  #time = 4
  scheduler$process_events(api)
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, api = api, target = c(2, 4))
})

test_that("you can see which individuals are scheduled for an event", {
  event <- Event$new('event')
  listener <- mockery::mock()
  api <- mockery::mock()
  event$add_listener(listener)

  scheduler <- Scheduler$new(5)

  #time = 0
  expect_null(scheduler$get_scheduled(event))

  #time = 1
  scheduler$schedule(event, c(2, 4), 2)
  scheduler$process_events(api)
  expect_setequal(scheduler$get_scheduled(event), c(2, 4))
  scheduler$tick()

  #time = 2
  scheduler$schedule(event, c(3, 4), 1)
  scheduler$process_events(api)
  expect_setequal(scheduler$get_scheduled(event), c(2, 3, 4))
  scheduler$tick()

  #time = 3
  scheduler$process_events(api)
  expect_setequal(scheduler$get_scheduled(event), c(2, 3, 4))
  scheduler$tick()

  #time = 4
  scheduler$process_events(api)
  expect_null(scheduler$get_scheduled(event))
})

test_that("events can be cleared for an individual", {
  event <- Event$new('event')
  listener <- mockery::mock()
  api <- mockery::mock()
  event$add_listener(listener)
  scheduler <- Scheduler$new(5)

  #time = 0
  expect_null(scheduler$get_scheduled(event))

  #time = 1
  scheduler$schedule(event, c(2, 3, 4), 1)
  scheduler$process_events(api)
  expect_setequal(scheduler$get_scheduled(event), c(2, 3, 4))
  scheduler$tick()

  #time = 2
  scheduler$clear_schedule(event, c(3, 4))
  expect_setequal(scheduler$get_scheduled(event), c(2))
  scheduler$process_events(api)
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, api = api, target = c(2))
})
