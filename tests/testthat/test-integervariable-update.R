# subset update (index and values of same length)

test_that("IntegerVariable queue/update works with verifiable input (subset update: vector)", {
  
  # normal updating
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  first <- variable$get_values()
  variable$queue_update((1:5) * 2, 1:5)
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(rep(11, 5), 2:6)
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
  
  variable$queue_update(values = 10:5, index = 1:6)
  variable$queue_update(values = 4:1, index = 7:10)
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  # does not update if index is size zero 
  variable$queue_update(values = 1:5, index = integer(0))
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  variable$queue_update(values = 1:5, index = numeric(0))
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  # does not update if values is size zero and index is non-zero
  before <- variable$get_values()
  variable$queue_update(values = numeric(0), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  before <- variable$get_values()
  variable$queue_update(values = integer(0), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), before)
  
})

test_that("IntegerVariable queue/update fails with incorrect input (subset update: vector)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  # bad index
  expect_error(variable$queue_update(values = 1:5, index = 51:55)) # out of bounds
  expect_error(variable$queue_update(values = 1:5, index = 1:10)) # not same length
  expect_error(variable$queue_update(values = 1:5, index = -5:0))
  expect_error(variable$queue_update(values = 1:5, index = NULL))
  expect_error(variable$queue_update(values = 1:5, index = NaN))
  expect_error(variable$queue_update(values = 1:5, index = c(1, NaN)))
  expect_error(variable$queue_update(values = 1:5, index = NA))
  expect_error(variable$queue_update(values = 1:5, index = c(1, NA)))
  expect_error(variable$queue_update(values = 1:5, index = Inf))
  expect_error(variable$queue_update(values = 1:5, index = c(1, Inf)))
  expect_error(variable$queue_update(values = 1:5, index = -Inf))
  expect_error(variable$queue_update(values = 1:5, index = c(1, -Inf)))
  
  # bad values
  expect_error(variable$queue_update(values = c(Inf, 1), index = c(1, 2)))
  expect_error(variable$queue_update(values = c(-Inf, 1), index = c(1, 2)))
  expect_error(variable$queue_update(values = c("5", 1), index = c(1, 2)))
  expect_error(variable$queue_update(values = c(NaN, 1), index = c(1, 2)))
  expect_error(variable$queue_update(values = c(NA, 1), index = c(1, 2)))
  expect_error(variable$queue_update(values = NULL, index = c(1, 2)))
  
})

test_that("IntegerVariable queue/update works with verifiable input (subset update: bitset)", {
  
  # normal updating
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  first <- variable$get_values()
  variable$queue_update((1:5) * 2, Bitset$new(size = size)$insert(1:5))
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(rep(11, 5), Bitset$new(size = size)$insert(2:6))
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
  
  variable$queue_update(values = 10:5, index = Bitset$new(size = size)$insert(1:6))
  variable$queue_update(values = 4:1, index = Bitset$new(size = size)$insert(7:10))
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  variable$queue_update(values = 1:5, index = Bitset$new(size = size))
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  variable$queue_update(values = 1:5, index = Bitset$new(size = size))
  variable$.update()
  expect_equal(variable$get_values(), 10:1)
  
  # does not update if index is size zero 
  before <- variable$get_values()
  variable$queue_update(values = 1:50, index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  # does not update if values is size zero and index is non-zero
  before <- variable$get_values()
  variable$queue_update(values = numeric(0), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  before <- variable$get_values()
  variable$queue_update(values = integer(0), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
})

test_that("IntegerVariable queue/update fails with incorrect input (subset update: bitset)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  expect_error(variable$queue_update(values = 1:5, index = Bitset$new(size = size + 10)))
  expect_error(variable$queue_update(values = 1:5, index = Bitset$new(size = size + 10)$insert(1)))
  
  # bad values
  expect_error(variable$queue_update(values = c(Inf, 1), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = c(-Inf, 1), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = c("5", 1), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = c(NaN, 1), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = c(NA, 1), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = NULL, index = Bitset$new(size = size)$insert(1:2)))
  
})


# subset fill (index of some length, values of length 1)

test_that("IntegerVariable queue/update works with verifiable input (subset fill: vector)", {
  
  # normal updating
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  first <- variable$get_values()
  variable$queue_update(2, 1:3)
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(11, 2:4)
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, 1:10)
  expect_equal(middle, c(2, 2, 2, 4:10))
  expect_equal(last, c(2, 11, 11, 11, 5:10))
  
  variable$queue_update(values = 10, index = 1:6)
  variable$queue_update(values = 1, index = 7:10)
  variable$.update()
  expect_equal(variable$get_values(), rep(c(10, 1), times = c(6, 4)))
  
  # does not update if values are size zero 
  variable <- IntegerVariable$new(seq_len(size))
  variable$queue_update(values = numeric(0), index = 1:10)
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  variable$queue_update(values = integer(0), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  # does not update if index are size zero 
  variable <- IntegerVariable$new(seq_len(size))
  variable$queue_update(values = 1, index = integer(0))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  variable$queue_update(values = 1, index = numeric(0))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
})

test_that("IntegerVariable queue/update fails with incorrect input (subset fill: vector)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  # bad index
  expect_error(variable$queue_update(values = 1, index = 51:55)) # out of bounds
  expect_error(variable$queue_update(values = 1, index = -5:0))
  expect_error(variable$queue_update(values = 1, index = NaN))
  expect_error(variable$queue_update(values = 1, index = c(1, NaN)))
  expect_error(variable$queue_update(values = 1, index = NA))
  expect_error(variable$queue_update(values = 1, index = c(1, NA)))
  expect_error(variable$queue_update(values = 1, index = Inf))
  expect_error(variable$queue_update(values = 1, index = c(1, Inf)))
  expect_error(variable$queue_update(values = 1, index = -Inf))
  expect_error(variable$queue_update(values = 1, index = c(1, -Inf)))
  
  # bad values
  expect_error(variable$queue_update(values = Inf, index = c(1, 2)))
  expect_error(variable$queue_update(values = -Inf, index = c(1, 2)))
  expect_error(variable$queue_update(values = "5", index = c(1, 2)))
  expect_error(variable$queue_update(values = NaN, index = c(1, 2)))
  expect_error(variable$queue_update(values = NA, index = c(1, 2)))
  expect_error(variable$queue_update(values = NULL, index = c(1, 2)))
  
})

test_that("IntegerVariable queue/update works with verifiable input (subset fill: bitset)", {
  
  # normal updating
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  first <- variable$get_values()
  variable$queue_update(2, Bitset$new(size)$insert(1:3))
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(11, Bitset$new(size)$insert(2:4))
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, 1:10)
  expect_equal(middle, c(2, 2, 2, 4:10))
  expect_equal(last, c(2, 11, 11, 11, 5:10))
  
  variable$queue_update(values = 10, index = Bitset$new(size)$insert(1:6))
  variable$queue_update(values = 1, index = Bitset$new(size)$insert(7:10))
  variable$.update()
  expect_equal(variable$get_values(), rep(c(10, 1), times = c(6, 4)))
  
  # does not update if values are size zero 
  variable <- IntegerVariable$new(seq_len(size))
  variable$queue_update(values = numeric(0), index = Bitset$new(size)$insert(1:10))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  variable$queue_update(values = integer(0), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  # does not update if index are size zero 
  variable <- IntegerVariable$new(seq_len(size))
  variable$queue_update(values = 1, index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
  variable$queue_update(values = 1, index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), 1:10)
  
})

test_that("IntegerVariable queue/update fails with incorrect input (subset fill: bitset)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  # bad index
  expect_error(variable$queue_update(values = 1, index = Bitset$new(size + 100)$insert(1:50)))
  expect_error(variable$queue_update(values = 1, index = Bitset$new(size + 100)))
  
  # bad values
  expect_error(variable$queue_update(values = Inf, index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = -Inf, index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = "5", index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = NaN, index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = NA, index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = NULL, index = Bitset$new(size)$insert(1:2)))
  
})


# variable reset (index NULL, values equal to variable size)

test_that("IntegerVariable queue/update works with verifiable input (variable reset)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  before <- variable$get_values()
  variable$queue_update(11:20)
  variable$.update()
  after <- variable$get_values()
  
  expect_equal(before, 1:10)
  expect_equal(after, 11:20)
})

test_that("IntegerVariable queue/update fails with incorrect input (variable reset)", {
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  expect_error(variable$queue_update(values = 1:1000, index = NULL))
  expect_error(variable$queue_update(values = -100:-10, index = NULL))
  expect_error(variable$queue_update(values = rep(NaN, size), index = NULL))
  expect_error(variable$queue_update(values = rep(NULL, size), index = NULL))
  expect_error(variable$queue_update(values = rep(NA, size), index = NULL))
  expect_error(variable$queue_update(values = rep(Inf, size), index = NULL))
  expect_error(variable$queue_update(values = rep(-Inf, size), index = NULL))
  expect_error(variable$queue_update(values = rep(c(NaN, 1), times = c(size-1 ,1)), index = NULL))
  expect_error(variable$queue_update(values = rep(c(NULL, 1), times = c(size-1 ,1)), index = NULL))
  expect_error(variable$queue_update(values = rep(c(NA, 1), times = c(size-1 ,1)), index = NULL))
  expect_error(variable$queue_update(values = rep(c(Inf, 1), times = c(size-1 ,1)), index = NULL))
  expect_error(variable$queue_update(values = rep(c(-Inf, 1), times = c(size-1 ,1)), index = NULL))
  
})


# variable fill (index NULL, values length 1)

test_that("IntegerVariable queue/update works with verifiable input (variable fill)", {
  
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  variable$queue_update(values = 100, index = NULL)
  variable$.update()
  expect_equal(variable$get_values(), rep(100, size))
  
})

test_that("IntegerVariable queue/update fails with incorrect input (variable fill)", {
  
  size <- 10
  variable <- IntegerVariable$new(seq_len(size))
  
  expect_error(variable$queue_update(values = Inf, index = NULL))
  expect_error(variable$queue_update(values = -Inf, index = NULL))
  expect_error(variable$queue_update(values = NaN, index = NULL))
  expect_error(variable$queue_update(values = NULL, index = NULL))
  expect_error(variable$queue_update(values = NA, index = NULL))
  expect_error(variable$queue_update(values = "5", index = NULL))
  
})
