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

test_that("events can be scheduled for for a Real time", {
  event <- Event$new('event')
  listener <- mockery::mock()
  api <- mockery::mock()
  event$add_listener(listener)
  scheduler <- Scheduler$new(5)
  #time = 0
  scheduler$schedule(event, c(2, 4), 1.9)

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

test_that("multiple events can be scheduled", {
  event1 <- Event$new('event1')
  event2 <- Event$new('event2')
  listener1 <- mockery::mock()
  listener2 <- mockery::mock()
  api <- mockery::mock()
  event1$add_listener(listener1)
  event2$add_listener(listener2)

  scheduler <- Scheduler$new(3)

  #time = 0
  expect_null(scheduler$get_scheduled(event1))
  expect_null(scheduler$get_scheduled(event2))

  #time = 1
  scheduler$schedule(event1, c(2, 4), 2)
  scheduler$schedule(event2, c(1, 3), 2)
  scheduler$process_events(api)
  expect_setequal(scheduler$get_scheduled(event1), c(2, 4))
  expect_setequal(scheduler$get_scheduled(event2), c(1, 3))

  scheduler$tick()
  scheduler$tick()
  scheduler$process_events(api)

  mockery::expect_called(listener1, 1)
  mockery::expect_called(listener2, 1)
  mockery::expect_args(listener1, 1, api = api, target = c(2, 4))
  mockery::expect_args(listener2, 1, api = api, target = c(1, 3))
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
