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