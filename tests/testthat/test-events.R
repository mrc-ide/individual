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

test_that("events can be scheduled for a real time", {
  event <- Event$new()
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2.1, 3.1))
  
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

test_that("events can be scheduled and canceled", {
  event <- Event$new()
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(1, 3))
  
  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()
  
  #time = 2
  event$.process()
  mockery::expect_called(listener, 1)
  event$.tick()
  
  #time = 3
  event$.process()
  mockery::expect_called(listener, 1)
  event$.tick()
  
  # cancel next one
  event$clear_schedule()
  
  #time = 4
  event$.process()
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, t = 2)
})

test_that("events can be saved and restored", {
  listener <- mockery::mock()

  old_event <- Event$new()
  old_event$add_listener(listener)

  # This schedules at t=2 and t=4
  old_event$schedule(c(1, 3))

  #time = 1
  old_event$.process()
  mockery::expect_called(listener, 0)
  old_event$.tick()

  #time = 2
  old_event$.process()
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, t = 2)
  old_event$.tick()

  new_event <- Event$new()
  new_event$add_listener(listener)
  new_event$.restore(
    old_event$.timestep(),
    old_event$.checkpoint())

  #time = 3
  new_event$.process()
  mockery::expect_called(listener, 1)
  new_event$.tick()

  #time = 4
  new_event$.process()
  mockery::expect_called(listener, 2)
  mockery::expect_args(listener, 2, t = 4)
})

test_that("events are cleared when restored", {
  listener <- mockery::mock()

  old_event <- Event$new()
  old_event$schedule(3) # t=4

  new_event <- Event$new()
  new_event$add_listener(listener)

  # Schedule at t=2. This will be cleared and overridden when restoring,
  # replaced by the earlier t=4 schedule.
  new_event$schedule(1)
  new_event$.restore(
    old_event$.timestep(),
    old_event$.checkpoint())

  #time=1
  new_event$.process()
  mockery::expect_called(listener, 0)
  new_event$.tick()

  #time=2
  new_event$.process()
  mockery::expect_called(listener, 0)
  new_event$.tick()

  #time=2
  new_event$.process()
  mockery::expect_called(listener, 0)
  new_event$.tick()

  #time=4
  new_event$.process()
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, t = 4)
  new_event$.tick()
})

test_that("empty event never triggers", {
  event <- Event$new()
  listener <- mockery::mock()
  event$add_listener(listener)

  for (i in seq(100)) {
    event$.process()
    event$.tick()
  }

  mockery::expect_called(listener, 0)
})
