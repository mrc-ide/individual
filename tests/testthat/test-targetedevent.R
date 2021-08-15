test_that("targeted events can be scheduled for the future (vector)", {
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

test_that("targeted events can be scheduled for the future (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(Bitset$new(10)$insert(c(2,4)), 2)
  
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

test_that("events can be scheduled for for a Real time (vector)", {
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

test_that("events can be scheduled for for a Real time (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(Bitset$new(10)$insert(c(2,4)), 1.9)
  
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

test_that("empty update targets do not call listener (vector)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(integer(0), 1)
  
  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()
  
  #time = 2
  event$.process()
  mockery::expect_called(listener, 0)
})

test_that("empty update targets do not call listener (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(Bitset$new(10), 1)
  
  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()
  
  #time = 2
  event$.process()
  mockery::expect_called(listener, 0)
})

test_that("you can schedule different times for a target population (vector)", {
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

test_that("you can schedule different times for a target population (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(Bitset$new(10)$insert(c(1, 2, 3, 4, 8)), c(1, 3, 1, 2, 2))
  
  #time = 1
  event$.process()
  mockery::expect_called(listener, 0)
  event$.tick()
  
  #time = 2
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 2, target = c(1, 3))
  event$.tick()
  
  #time = 3
  event$.process()
  mockery::expect_called(listener, 2)
  expect_targeted_listener(listener, 2, t = 3, target = c(4, 8))
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
  expect_error(
    event$schedule(Bitset$new(10)$insert(c(1, 2, 4, 8, 3)), c(1, 3, 1, 2)),
    '*'
  )
  expect_error(
    event$schedule(Bitset$new(10)$insert(c(1, 2, 4, 8, 3)), c(1, 3, 1, 2, -1)),
    '*'
  )
})

test_that("you can see which individuals are scheduled for an event (vector)", {
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

test_that("you can see which individuals are scheduled for an event (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  
  expect_length(event$get_scheduled()$to_vector(), 0)
  
  #time = 1
  event$schedule(Bitset$new(10)$insert(c(2, 4)), 2)
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 4))
  event$.tick()
  
  #time = 2
  event$schedule(Bitset$new(10)$insert(c(3, 4)), 1)
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

test_that("multiple events can be scheduled (vector)", {
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

test_that("multiple events can be scheduled (bitset)", {
  event1 <- TargetedEvent$new(10)
  event2 <- TargetedEvent$new(10)
  listener1 <- mockery::mock()
  listener2 <- mockery::mock()
  event1$add_listener(listener1)
  event2$add_listener(listener2)
  
  expect_length(event1$get_scheduled()$to_vector(), 0)
  expect_length(event2$get_scheduled()$to_vector(), 0)
  
  #time = 1
  event1$schedule(Bitset$new(10)$insert(c(2, 4)), 1)
  event2$schedule(Bitset$new(10)$insert(c(1, 3)), 1)
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

test_that("events can be cleared for an individual (vector)", {
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

test_that("events can be cleared for an individual (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  
  expect_length(event$get_scheduled()$to_vector(), 0)
  
  #time = 1
  event$schedule(Bitset$new(10)$insert(c(2, 3, 4)), 1)
  event$.process()
  expect_setequal(event$get_scheduled()$to_vector(), c(2, 3, 4))
  event$.tick()
  
  #time = 2
  event$clear_schedule(Bitset$new(10)$insert(c(3, 4)))
  expect_setequal(event$get_scheduled()$to_vector(), 2)
  event$.process()
  mockery::expect_called(listener, 1)
  expect_targeted_listener(listener, 1, t = 2, target = 2)
})

test_that("targeted events work for scalar delay, vector target", {
  
  # works as expected
  event <- TargetedEvent$new(10)
  target <- 1:5
  delay <- 5
  event$schedule(target = target,delay = delay)
  expect_equal(event$get_scheduled()$to_vector(), target)
  
  # fails as expected (bad target)
  event <- TargetedEvent$new(10)
  target <- -5:5
  delay <- 5
  expect_error(event$schedule(target = target,delay = delay))
  
  target <- 11:20
  expect_error(event$schedule(target = target,delay = delay))
  
  target <- c(Inf,5)
  expect_error(event$schedule(target = target,delay = delay))
  
  target <- c(NaN,5)
  expect_error(event$schedule(target = target,delay = delay))
  
  # fails as expected (bad delay)
  event <- TargetedEvent$new(10)
  target <- 1:5
  delay <- -5
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- NaN
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- numeric(0)
  expect_error(event$schedule(target = target,delay = delay))
  
})

test_that("targeted events work for scalar delay, bitset target", {
  
  # works as expected
  event <- TargetedEvent$new(10)
  target <- Bitset$new(10)$insert(1:5)
  delay <- 5
  event$schedule(target = target,delay = delay)
  expect_equal(event$get_scheduled()$to_vector(), target$to_vector())
  
  # fails as expected (bad target)
  event <- TargetedEvent$new(10)
  target <- Bitset$new(20)$insert(11:20)
  delay <- 5
  expect_error(event$schedule(target = target,delay = delay))
  
  # fails as expected (bad delay)
  event <- TargetedEvent$new(10)
  target <- Bitset$new(10)$insert(1:5)
  delay <- NaN
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- numeric(0)
  expect_error(event$schedule(target = target,delay = delay))
  
})

test_that("targeted events work for vector delay, vector target", {
  
  # works as expected
  event <- TargetedEvent$new(10)
  target <- 1:5
  delay <- 1:5
  event$schedule(target = target,delay = delay)
  expect_equal(event$get_scheduled()$to_vector(), target)
  
  # fails as expected (bad target)
  event <- TargetedEvent$new(10)
  target <- -5:5
  delay <- 1:5
  expect_error(event$schedule(target = target,delay = delay))
  
  # fails as expected (bad target)
  event <- TargetedEvent$new(10)
  target <- c(Inf,5)
  delay <- c(1,1)
  expect_error(event$schedule(target = target,delay = delay))

  target <- c(NaN,5)
  expect_error(event$schedule(target = target,delay = delay))
  
  # fails as expected (bad delay)
  event <- TargetedEvent$new(10)
  target <- 1:5
  delay <- c(NaN,1,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))

  delay <- c(1,Inf,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- c(1,NA,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- numeric(0)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- c(-1,1,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- rep(0,10)
  expect_error(event$schedule(target = target,delay = delay))
  
})

test_that("targeted events work for vector delay, bitset target", {
  
  # works as expected
  event <- TargetedEvent$new(10)
  target <- Bitset$new(10)$insert(1:5)
  delay <- 1:5
  event$schedule(target = target,delay = delay)
  expect_equal(event$get_scheduled()$to_vector(), target$to_vector())
  
  # fails as expected (bad target)
  event <- TargetedEvent$new(10)
  target <- Bitset$new(20)$insert(1)
  delay <- 1:5
  expect_error(event$schedule(target = target,delay = delay))
  
  # fails as expected (bad delay)
  event <- TargetedEvent$new(10)
  target <- Bitset$new(10)$insert(1:5)
  delay <- c(NaN,1,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- c(1,Inf,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- c(1,NA,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- numeric(0)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- c(-1,1,1,1,1)
  expect_error(event$schedule(target = target,delay = delay))
  
  delay <- rep(0,10)
  expect_error(event$schedule(target = target,delay = delay))
  
})
