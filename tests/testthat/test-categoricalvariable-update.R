test_that("catagorical updates work", {
  state <- CategoricalVariable$new(
    c('S', 'I'),
    rep('S', 10)
  )
  state$queue_update('I', c(1, 3))
  state$.update()
  expect_setequal(state$get_index_of('I')$to_vector(), c(1, 3))
  expect_setequal(state$get_index_of('S')$to_vector(), c(2, 4:10))
})

test_that("catagorical updates work after null updates", {
  state <- CategoricalVariable$new(
    c('S', 'I'),
    rep('S', 10)
  )
  state$queue_update('I', numeric(0))
  state$.update()
  expect_setequal(state$get_index_of('I')$to_vector(), numeric(0))
  expect_setequal(state$get_index_of('S')$to_vector(), seq(10))
  state$queue_update('I', c(1, 3))
  state$.update()
  expect_setequal(state$get_index_of('I')$to_vector(), c(1, 3))
  expect_setequal(state$get_index_of('S')$to_vector(), c(2, 4:10))
})


test_that("catagorical updates work with duplicate elements", {
  state <- CategoricalVariable$new(
    c('S', 'I'),
    rep('S', 10)
  )
  state$queue_update('I', c(1, 1, 3, 3))
  state$.update()
  expect_setequal(state$get_index_of('I')$to_vector(), c(1, 3))
  expect_setequal(state$get_index_of('S')$to_vector(), c(2, 4:10))
})

test_that("Queuing invalid category errors", {
  population <- 10
  state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
  expect_error(variable$queue_update("X", Bitset$new(1)$insert(1)),
               '*'
  )
})

test_that("Queuing invalid indices errors", {
  c <- CategoricalVariable$new(categories = c("A","B"),initial_values = rep(c("A","B"),each=10))
  expect_error(c$queue_update(value = "A",index = c(15, 25, 50)))
  expect_error(c$queue_update(value = "A",index = c(-5, 1)))
  expect_error(c$queue_update(value = "A",index = c(5, NaN)))
  expect_error(c$queue_update(value = "A",index = c(5, NA)))
  expect_error(c$queue_update(value = "A",index = Bitset$new(50)$insert(c(15, 25, 50))))
  expect_error(c$queue_update(value = "A",index = Bitset$new(30)$insert(c(15, 17))))
  expect_error(c$queue_update(value = "A",index = Bitset$new(1e2)))
})

test_that("Updates work correctly", {
  c <- CategoricalVariable$new(categories = c("A","B"),initial_values = rep(c("A","B"),each=10))
  b <- 1:5
  c$queue_update(value = "B", index = b)
  c$.update()
  expect_equal(c$get_index_of("A")$to_vector(), 6:10)
  b <- Bitset$new(20)$insert(1:5)
  c$queue_update(value = "A", index = b)
  c$.update()
  expect_equal(c$get_index_of("A")$to_vector(), 1:10)
})