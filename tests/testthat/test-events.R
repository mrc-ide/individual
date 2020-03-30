test_that("events can be scheduled for the future", {
  event <- Event$new('event')
  listener <- mockery::mock()
  simulation <- mockery::mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  scheduler <- Scheduler$new(list(human), simulation, 4)
  #time = 0
  scheduler$schedule(event, c(2, 4), 2)

  #time = 1
  scheduler$process_events()
  expect_called(listener, 0)
  simulation$tick()

  #time = 2
  scheduler$process_events()
  expect_called(listener, 0)
  scheduler$tick()

  #time = 3
  scheduler$process_events()
  expect_called(listener, 1)
  scheduler$tick()

  #time = 4
  scheduler$process_events()
  expect_called(listener, 1)
  expect_args(listener, 1, target = c(2, 4))
})

test_that("you can see which individuals are scheduled for an event", {
  event <- Event$new('event')
  listener <- mockery::mock()
  simulation <- mockery::mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  scheduler <- Scheduler$new(list(human), simulation, 4)
  api <- simulation$get_api()

  #time = 0
  expect_setequal(api$get_scheduled(event), c())

  #time = 1
  api$schedule(event, c(2, 4), 2)
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c(2, 4))
  simulation$tick()

  #time = 2
  api$schedule(event, c(3, 4), 1)
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c(2, 3, 4))
  simulation$tick()

  #time = 3
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c())
  simulation$tick()

  #time = 4
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c())
})

test_that("events can be cleared for an individual", {
  event <- Event$new('event')
  listener <- mockery::mock()
  simulation <- mockery::mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  scheduler <- Scheduler$new(list(human), simulation, 2)

  #time = 0
  expect_setequal(scheduler$get_scheduled(event), c())

  #time = 1
  scheduler$schedule(event, c(2, 3, 4), 1)
  scheduler$process_events()
  expect_setequal(scheduler$get_scheduled(event), c(2, 3, 4))
  scheduler$tick()

  #time = 2
  scheduler$clear_schedule(event, c(3, 4))
  expect_setequal(scheduler$get_scheduled(event), c(2))
  scheduler$process_events()
  expect_called(listener, 1)
  expect_args(listener, 1, target = c(2))
})
