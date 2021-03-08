test_that("first event is triggered at t=1", {
  event <- Event$new()
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(0, 1))

  #time = 1
  event$.process()
  mockery::expect_args(listener, 1, t = 1)
  event$.tick()

  #time = 2
  event$.process()
  mockery::expect_args(listener, 2, t = 2)
  event$.tick()
})

test_that("events can be scheduled for the future", {
  event <- Event$new()
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 3))

  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 2
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 3
  event$.process()
  mockery::expect_called(listener, 1)
  event$.tick()

  #time = 4
  event$.process()
  mockery::expect_called(listener, 2)
  mockery::expect_args(listener, 1, t = 3)
  mockery::expect_args(listener, 2, t = 4)
})

test_that("targeted events can be scheduled for the future", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 4), 2)

  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 2
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 3
  event$.process()
  mockery::expect_called(listener, 1)
  event$.tick()

  #time = 4
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 3, target = c(2, 4))
})

test_that("events can be scheduled for for a Real time", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 4), 1.9)

  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 2
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 3
  event$.process()
  mockery::expect_called(listener, 1)
  event$.tick()

  #time = 4
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 3, target = c(2, 4))
})

test_that("you can schedule different times for a target population", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(1, 2, 4, 8, 3), c(1, 3, 1, 2, 2))

  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()

  #time = 2
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 2, target = c(1, 4))
  event$.tick()

  #time = 3
  event$.process()
  mockery::expect_called(listener, 2)
  expect_targeted_listener(listener, 2, t = 3, target = c(3, 8))
  event$.tick()

  #time = 4
  event$.process()
  mockery::expect_called(listener, 3)
  expect_targeted_listener(listener, 3, t = 4, target = 2)
})

test_that("when you can schedule different times invalid times cause an error", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  expect_error(
    event$schedule(c(1, 2, 4, 8, 3), c(1, 3, 1, 2)),
    '*'
  )
  expect_error(
    event$schedule(c(1, 2, 4, 8, 3), c(1, 3, 1, 2, -1)),
    '*'
  )
})

test_that("you can see which individuals are scheduled for an event", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)

  expect_length(event$get_scheduled()$to_vector(), 0)

  #time = 1
  event$schedule(c(2, 4), 2)
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 4))
  event$.tick()

  #time = 2
  event$schedule(c(3, 4), 1)
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 3, 4))
  event$.tick()

  #time = 3
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 3, 4))
  event$.tick()

  #time = 4
  event$.process()
  expect_length(event$get_scheduled()$to_vector(), 0)
})

test_that("multiple events can be scheduled", {
  event1 <- TargetedEvent$new(10)
  event2 <- TargetedEvent$new(10)
  listener1 <- mockery::mock()
  listener2 <- mockery::mock()
  event1$add_listener(listener1)
  event2$add_listener(listener2)

  expect_length(event1$get_scheduled()$to_vector(), 0)
  expect_length(event2$get_scheduled()$to_vector(), 0)

  #time = 1
  event1$schedule(c(2, 4), 1)
  event2$schedule(c(1, 3), 1)
  event1$.process()
  event2$.process()
  expect_setequal(event1$get_scheduled()$to_vector(), c(2, 4))
  expect_setequal(event2$get_scheduled()$to_vector(), c(1, 3))

  event1$.tick()
  event2$.tick()
  event1$.process()
  event2$.process()

  mockery::expect_called(listener1, 1)
  mockery::expect_called(listener2, 1)
  expect_targeted_listener(listener1, 1, t = 2, target = c(2, 4))
  expect_targeted_listener(listener2, 1, t = 2, target = c(1, 3))
})

test_that("events can be cleared for an individual", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)

  expect_length(event$get_scheduled()$to_vector(), 0)

  #time = 1
  event$schedule(c(2, 3, 4), 1)
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 3, 4))
  event$.tick()

  #time = 2
  event$clear_schedule(c(3, 4))
  expect_setequal(event$get_scheduled()$to_vector(), 2)
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 2, target = 2)
})
