test_that("events can be scheduled for the future", {
  event <- Event$new('event')
  listener <- mockery::mock()
  event$add_listener(listener)
  scheduler <- create_scheduler(list(event))
  sim <- setup_simulation(scheduler = scheduler)
  #time = 0
  sim$r_api$schedule(event, c(2, 4), 2)

  #time = 1
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 0)
  scheduler_tick(sim$scheduler)

  #time = 2
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 0)
  scheduler_tick(sim$scheduler)

  #time = 3
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 1)
  scheduler_tick(sim$scheduler)

  #time = 4
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, api = sim$r_api, target = c(2, 4))
})

test_that("events can be scheduled for for a Real time", {
  event <- Event$new('event')
  listener <- mockery::mock()
  event$add_listener(listener)
  scheduler <- create_scheduler(list(event))
  sim <- setup_simulation(scheduler = scheduler)
  #time = 0
  sim$r_api$schedule(event, c(2, 4), 1.9)

  #time = 1
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 0)
  scheduler_tick(sim$scheduler)

  #time = 2
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 0)
  scheduler_tick(sim$scheduler)

  #time = 3
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 1)
  scheduler_tick(sim$scheduler)

  #time = 4
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, api = sim$r_api, target = c(2, 4))
})

test_that("you can see which individuals are scheduled for an event", {
  event <- Event$new('event')
  listener <- mockery::mock()
  event$add_listener(listener)

  scheduler <- create_scheduler(list(event))
  sim <- setup_simulation(scheduler = scheduler)

  #time = 0
  expect_length(sim$r_api$get_scheduled(event), 0)

  #time = 1
  sim$r_api$schedule(event, c(2, 4), 2)
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_setequal(sim$r_api$get_scheduled(event), c(2, 4))
  scheduler_tick(sim$scheduler)

  #time = 2
  sim$r_api$schedule(event, c(3, 4), 1)
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_setequal(sim$r_api$get_scheduled(event), c(2, 3, 4))
  scheduler_tick(sim$scheduler)

  #time = 3
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_setequal(sim$r_api$get_scheduled(event), c(2, 3, 4))
  scheduler_tick(sim$scheduler)

  #time = 4
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_length(sim$r_api$get_scheduled(event), 0)
})

test_that("multiple events can be scheduled", {
  event1 <- Event$new('event1')
  event2 <- Event$new('event2')
  listener1 <- mockery::mock()
  listener2 <- mockery::mock()
  event1$add_listener(listener1)
  event2$add_listener(listener2)

  scheduler <- create_scheduler(list(event1, event2))
  sim <- setup_simulation(scheduler = scheduler)

  #time = 0
  expect_length(sim$r_api$get_scheduled(event1), 0)
  expect_length(sim$r_api$get_scheduled(event2), 0)

  #time = 1
  sim$r_api$schedule(event1, c(2, 4), 2)
  sim$r_api$schedule(event2, c(1, 3), 2)
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_setequal(sim$r_api$get_scheduled(event1), c(2, 4))
  expect_setequal(sim$r_api$get_scheduled(event2), c(1, 3))

  scheduler_tick(sim$scheduler)
  scheduler_tick(sim$scheduler)
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)

  mockery::expect_called(listener1, 1)
  mockery::expect_called(listener2, 1)
  mockery::expect_args(listener1, 1, api = sim$r_api, target = c(2, 4))
  mockery::expect_args(listener2, 1, api = sim$r_api, target = c(1, 3))
})

test_that("events can be cleared for an individual", {
  event <- Event$new('event')
  listener <- mockery::mock()
  event$add_listener(listener)
  scheduler <- create_scheduler(list(event))
  sim <- setup_simulation(scheduler = scheduler)

  #time = 0
  expect_length(sim$r_api$get_scheduled(event), 0)

  #time = 1
  sim$r_api$schedule(event, c(2, 3, 4), 1)
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  expect_setequal(sim$r_api$get_scheduled(event), c(2, 3, 4))
  scheduler_tick(sim$scheduler)

  #time = 2
  sim$r_api$clear_schedule(event, c(3, 4))
  expect_setequal(sim$r_api$get_scheduled(event), c(2))
  scheduler_process_events(scheduler, sim$cpp_api, sim$r_api)
  mockery::expect_called(listener, 1)
  mockery::expect_args(listener, 1, api = sim$r_api, target = c(2))
})
