test_that("events can be scheduled for the future", {
  event <- Event$new('event')
  listener <- mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  simulation <- Simulation$new(human, 4)
  api <- simulation$get_api()
  #time = 0
  api$schedule(event, c(2, 4), 2)

  #time = 1
  simulation$tick()
  simulation$process_events()
  expect_called(listener, 0)

  #time = 2
  simulation$tick()
  simulation$process_events()
  expect_called(listener, 0)

  #time = 3
  simulation$tick()
  simulation$process_events()
  expect_called(listener, 1)

  #time = 4
  simulation$tick()
  simulation$process_events()
  expect_called(listener, 1)

  expect_args(listener, 1, target = c(2, 4))
})

test_that("you can see which individuals are scheduled for an event", {
  event <- Event$new('event')
  listener <- mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  simulation <- Simulation$new(human, 4)
  api <- simulation$get_api()

  #time = 0
  expect_setequal(api$get_scheduled(event), c())

  #time = 1
  simulation$tick()
  api$schedule(event, c(2, 4), 2)
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c(2, 4))

  #time = 2
  simulation$tick()
  api$schedule(event, c(3, 4), 1)
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c(2, 3, 4))

  #time = 3
  simulation$tick()
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c())

  #time = 4
  simulation$tick()
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c())
})

test_that("events can be cleared for an individual", {
  event <- Event$new('event')
  listener <- mock()
  event$add_listener(listener)
  human <- Individual$new(
    'human',
    list(State$new('default', 5)),
    events = list(event)
  )
  simulation <- Simulation$new(human, 2)
  api <- simulation$get_api()

  #time = 0
  expect_setequal(api$get_scheduled(event), c())

  #time = 1
  simulation$tick()
  api$schedule(event, c(2, 3, 4), 1)
  simulation$process_events()
  expect_setequal(api$get_scheduled(event), c(2, 3, 4))

  #time = 2
  simulation$tick()
  api$clear_schedule(event, c(3, 4))
  expect_setequal(api$get_scheduled(event), c(2))
  simulation$process_events()
  expect_called(listener, 1)
  expect_args(listener, 1, target = c(2))
})
