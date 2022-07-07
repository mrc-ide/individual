test_that("extending a TargetedEvent returns a larger bitset", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 4), 1)
  event$queue_extend(10)
  event$.resize()
  event$.tick()
  event$.process()
  expect_equal(
    mockery::mock_args(listener)[[1]][[2]]$max_size,
    20
  )
})

test_that("extending a TargetedEvent with a schedule works", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$queue_extend_with_schedule(c(1, 2))
  event$.resize()
  event$.tick()
  event$.process()
  expect_targeted_listener(listener, 1, t = 2, target = 11)
  event$.tick()
  event$.process()
  expect_targeted_listener(listener, 2, t = 3, target = 12)
})


test_that("TargetedEvent shrinking variables removes values (bitset)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 4), 1)
  event$queue_shrink(Bitset$new(10)$insert(2))
  event$.resize()
  event$.tick()
  event$.process()
  expect_targeted_listener(listener, 1, t = 2, target = 3)
  expect_equal(
    mockery::mock_args(listener)[[1]][[2]]$max_size,
    9
  )
})

test_that("TargetedEvent shrinking variables removes values (vector)", {
  event <- TargetedEvent$new(10)
  listener <- mockery::mock()
  event$add_listener(listener)
  event$schedule(c(2, 4), 1)
  event$queue_shrink(4)
  event$.resize()
  event$.tick()
  event$.process()
  expect_targeted_listener(listener, 1, t = 2, target = 2)
  expect_equal(
    mockery::mock_args(listener)[[1]][[2]]$max_size,
    9
  )
})

test_that("TargetedEvent invalid shrinking operations error at queue time", {
  x <- TargetedEvent$new(10)
  expect_error(x$queue_shrink(index = 1:20))
  expect_error(x$queue_shrink(index = -1:20))
  expect_error(x$queue_shrink(index = Bitset$new(20)$insert(1:20)))
})
