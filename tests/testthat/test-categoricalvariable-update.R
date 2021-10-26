SIR <- c('S', 'I', 'R')

test_that("CategoricalVariable updates work", {
  variable <- CategoricalVariable$new(SIR, rep('S', 10))
  
  variable$queue_update('I', c(1, 3))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), c(1, 3))
  expect_setequal(variable$get_index_of('S')$to_vector(), c(2, 4:10))
  
  variable$queue_update(value = 'R', index = 10)
  variable$.update()
  expect_setequal(variable$get_index_of('R')$to_vector(), 10)
  
  variable$queue_update(value = 'I', index = Bitset$new(10)$insert(10))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), c(1, 3, 10))
  
  variable$queue_update(value = 'R', index = Bitset$new(10)$insert(c(1, 5)))
  variable$.update()
  expect_setequal(variable$get_index_of('R')$to_vector(), c(1, 5))
  
  variable$queue_update(value = 'R', index = Bitset$new(10)$insert(1:10))
  variable$.update()
  expect_setequal(variable$get_index_of('R')$to_vector(), 1:10)
  
  variable$queue_update(value = 'S', index = 1:10)
  variable$.update()
  expect_setequal(variable$get_index_of('S')$to_vector(), 1:10)
})

test_that("CategoricalVariable updates work after null updates", {
  variable <- CategoricalVariable$new(SIR, rep('S', 10))
  
  variable$queue_update('I', numeric(0))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), numeric(0))
  expect_setequal(variable$get_index_of('S')$to_vector(), seq(10))
  
  variable$queue_update('I', integer(0))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), numeric(0))
  
  variable$queue_update('I', NULL)
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), numeric(0))
  
  variable$queue_update('I', Bitset$new(10))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), numeric(0))
})


test_that("CategoricalVariable updates work with duplicate elements", {
  variable <- CategoricalVariable$new(SIR, rep('S', 10))
  
  variable$queue_update('I', c(1, 1, 3, 3))
  variable$.update()
  expect_setequal(variable$get_index_of('I')$to_vector(), c(1, 3))
  expect_setequal(variable$get_index_of('S')$to_vector(), c(2, 4:10))
  
  variable$queue_update('R', Bitset$new(10)$insert(c(1, 1, 3, 3)))
  variable$.update()
  expect_setequal(variable$get_index_of('R')$to_vector(), c(1, 3))
  expect_setequal(variable$get_index_of('S')$to_vector(), c(2, 4:10))
})

test_that("Queuing invalid CategoricalVariable category updates errors", {
  population <- 10
  variable <- CategoricalVariable$new(SIR, rep('S', population))
  expect_error(variable$queue_update("X", Bitset$new(population)$insert(1)))
  expect_error(variable$queue_update("X", Bitset$new(population)))
  expect_error(variable$queue_update("X", 1:5))
  expect_error(variable$queue_update(c('S', 'I'), 1:5))
  expect_error(variable$queue_update(rep("I", 5), 1:5))
  expect_error(variable$queue_update(NULL, 1:5))
  expect_error(variable$queue_update(NaN, 1:5))
  expect_error(variable$queue_update(NA, 1:5))
  expect_error(variable$queue_update(5, 1:5))
})

test_that("Queuing invalid CategoricalVariable indices errors", {
  variable <- CategoricalVariable$new(categories = SIR, initial_values = rep(SIR, each = 10))
  expect_error(variable$queue_update(value = "S",index = c(15, 25, 50)))
  expect_error(variable$queue_update(value = "S",index = c(-5, 1)))
  expect_error(variable$queue_update(value = "S",index = c(5, NaN)))
  expect_error(variable$queue_update(value = "S",index = c(5, NA)))
  expect_error(variable$queue_update(value = "S",index = 100:120))
  expect_error(variable$queue_update(value = "S",index = Bitset$new(50)$insert(c(15, 25, 50))))
  expect_error(variable$queue_update(value = "S",index = Bitset$new(40)$insert(c(15, 17))))
  expect_error(variable$queue_update(value = "S",index = Bitset$new(1e2)))
})