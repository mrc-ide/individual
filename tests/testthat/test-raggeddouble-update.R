# subset update (index and values of same length)

test_that("RaggedDouble queue/update works with verifiable input (subset update: vector)", {
  
  # normal updating
  size <- 10
  vals <- as.list(seq_len(size))
  variable <- RaggedDouble$new(vals)
  
  first <- variable$get_values()
  variable$queue_update(as.list((1:5) * 2), 1:5)
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(as.list(rep(11, 5)), 2:6)
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, as.list(1:10))
  expect_equal(middle, as.list(c((1:5) * 2, 6:10)))
  expect_equal(last, as.list(c(2, rep(11, 5), 7:10)))
  
  variable$queue_update(values = as.list(10:5), index = 1:6)
  variable$queue_update(values = as.list(4:1), index = 7:10)
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  # does not update if index is size zero 
  variable$queue_update(values = as.list(1:5), index = integer(0))
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  variable$queue_update(values = as.list(1:5), index = numeric(0))
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  # does not update if values is size zero and index is non-zero
  before <- variable$get_values()
  variable$queue_update(values = list(), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  before <- variable$get_values()
  variable$queue_update(values = list(), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), before)
  
})

test_that("RaggedDouble queue/update fails with incorrect input (subset update: vector)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  # bad index
  expect_error(variable$queue_update(values = as.list(1:5), index = 51:55)) # out of bounds
  expect_error(variable$queue_update(values = as.list(1:5), index = 1:10)) # not same length
  expect_error(variable$queue_update(values = as.list(1:5), index = -5:0))
  expect_error(variable$queue_update(values = as.list(1:5), index = NULL))
  expect_error(variable$queue_update(values = as.list(1:5), index = NaN))
  expect_error(variable$queue_update(values = as.list(1:5), index = c(1, NaN)))
  expect_error(variable$queue_update(values = as.list(1:5), index = NA))
  expect_error(variable$queue_update(values = as.list(1:5), index = c(1, NA)))
  expect_error(variable$queue_update(values = as.list(1:5), index = Inf))
  expect_error(variable$queue_update(values = as.list(1:5), index = c(1, Inf)))
  expect_error(variable$queue_update(values = as.list(1:5), index = -Inf))
  expect_error(variable$queue_update(values = as.list(1:5), index = c(1, -Inf)))
  
  # bad values
  expect_error(variable$queue_update(values = as.list(c("5", 1)), index = c(1, 2)))
  expect_error(variable$queue_update(values = NULL, index = c(1, 2)))
  
})

test_that("RaggedDouble queue/update works with verifiable input (subset update: bitset)", {
  
  # normal updating
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  first <- variable$get_values()
  variable$queue_update(as.list((1:5) * 2), Bitset$new(size = size)$insert(1:5))
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(as.list(rep(11, 5)), Bitset$new(size = size)$insert(2:6))
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, as.list(1:10))
  expect_equal(middle, as.list(c((1:5) * 2, 6:10)))
  expect_equal(last, as.list(c(2, rep(11, 5), 7:10)))
  
  variable$queue_update(values = as.list(10:5), index = Bitset$new(size = size)$insert(1:6))
  variable$queue_update(values = as.list(4:1), index = Bitset$new(size = size)$insert(7:10))
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  variable$queue_update(values = as.list(1:5), index = Bitset$new(size = size))
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  variable$queue_update(values = as.list(1:5), index = Bitset$new(size = size))
  variable$.update()
  expect_equal(variable$get_values(), as.list(10:1))
  
  # does not update if index is size zero 
  before <- variable$get_values()
  variable$queue_update(values = as.list(1:5), index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  # does not update if values is size zero and index is non-zero
  before <- variable$get_values()
  variable$queue_update(values = list(), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
  before <- variable$get_values()
  variable$queue_update(values = list(), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), before)
  
})

test_that("RaggedDouble queue/update fails with incorrect input (subset update: bitset)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  expect_error(variable$queue_update(values = as.list(1:5), index = Bitset$new(size = size + 10)))
  expect_error(variable$queue_update(values = as.list(1:5), index = Bitset$new(size = size + 10)$insert(1)))
  
  # bad values
  expect_error(variable$queue_update(values = as.list(c("5", 1)), index = Bitset$new(size = size)$insert(1:2)))
  expect_error(variable$queue_update(values = NULL, index = Bitset$new(size = size)$insert(1:2)))
  
})


# subset fill (index of some length, values of length 1)

test_that("RaggedDouble queue/update works with verifiable input (subset fill: vector)", {
  
  # normal updating
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  first <- variable$get_values()
  variable$queue_update(as.list(2), 1:3)
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(as.list(11), 2:4)
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, as.list(1:10))
  expect_equal(middle, as.list(c(2, 2, 2, 4:10)))
  expect_equal(last, as.list(c(2, 11, 11, 11, 5:10)))
  
  variable$queue_update(values = as.list(10), index = 1:6)
  variable$queue_update(values = as.list(1), index = 7:10)
  variable$.update()
  expect_equal(variable$get_values(), as.list(rep(c(10, 1), times = c(6, 4))))
  
  # does not update if values are size zero 
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  variable$queue_update(values = list(), index = 1:10)
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  variable$queue_update(values = list(), index = 1:5)
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  # does not update if index are size zero 
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  variable$queue_update(values = as.list(1), index = integer(0))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  variable$queue_update(values = as.list(1), index = numeric(0))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
})

test_that("RaggedDouble queue/update fails with incorrect input (subset fill: vector)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  # bad index
  expect_error(variable$queue_update(values = as.list(1), index = 51:55)) # out of bounds
  expect_error(variable$queue_update(values = as.list(1), index = -5:0))
  expect_error(variable$queue_update(values = as.list(1), index = NaN))
  expect_error(variable$queue_update(values = as.list(1), index = c(1, NaN)))
  expect_error(variable$queue_update(values = as.list(1), index = NA))
  expect_error(variable$queue_update(values = as.list(1), index = c(1, NA)))
  expect_error(variable$queue_update(values = as.list(1), index = Inf))
  expect_error(variable$queue_update(values = as.list(1), index = c(1, Inf)))
  expect_error(variable$queue_update(values = as.list(1), index = -Inf))
  expect_error(variable$queue_update(values = as.list(1), index = c(1, -Inf)))
  
  # bad values
  expect_error(variable$queue_update(values = as.list("5"), index = c(1, 2)))
  expect_error(variable$queue_update(values = NULL, index = c(1, 2)))
  
})

test_that("RaggedDouble queue/update works with verifiable input (subset fill: bitset)", {
  
  # normal updating
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  first <- variable$get_values()
  variable$queue_update(as.list(2), Bitset$new(size)$insert(1:3))
  variable$.update()
  middle <- variable$get_values()
  variable$queue_update(as.list(11), Bitset$new(size)$insert(2:4))
  variable$.update()
  last <- variable$get_values()
  
  expect_equal(first, as.list(1:10))
  expect_equal(middle, as.list(c(2, 2, 2, 4:10)))
  expect_equal(last, as.list(c(2, 11, 11, 11, 5:10)))
  
  variable$queue_update(values = as.list(10), index = Bitset$new(size)$insert(1:6))
  variable$queue_update(values = as.list(1), index = Bitset$new(size)$insert(7:10))
  variable$.update()
  expect_equal(variable$get_values(), as.list(rep(c(10, 1), times = c(6, 4))))
  
  # does not update if values are size zero 
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  variable$queue_update(values = list(), index = Bitset$new(size)$insert(1:10))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  variable$queue_update(values = list(), index = Bitset$new(size)$insert(1:5))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  # does not update if index are size zero 
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  variable$queue_update(values = as.list(1), index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
  variable$queue_update(values = as.list(1), index = Bitset$new(size))
  variable$.update()
  expect_equal(variable$get_values(), as.list(1:10))
  
})

test_that("RaggedDouble queue/update fails with incorrect input (subset fill: bitset)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  # bad index
  expect_error(variable$queue_update(values = as.list(1), index = Bitset$new(size + 100)$insert(1:50)))
  expect_error(variable$queue_update(values = as.list(1), index = Bitset$new(size + 100)))
  
  # bad values
  expect_error(variable$queue_update(values = as.list("5"), index = Bitset$new(size)$insert(1:2)))
  expect_error(variable$queue_update(values = NULL, index = Bitset$new(size)$insert(1:2)))
  
})


# variable reset (index NULL, values equal to variable size)

test_that("RaggedDouble queue/update works with verifiable input (variable reset)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  before <- variable$get_values()
  variable$queue_update(as.list(11:20))
  variable$.update()
  after <- variable$get_values()
  
  expect_equal(before, as.list(1:10))
  expect_equal(after, as.list(11:20))
})

test_that("RaggedDouble queue/update fails with incorrect input (variable reset)", {
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  expect_error(variable$queue_update(values = as.list(1:1000), index = NULL))
  expect_error(variable$queue_update(values = as.list(-100:-10), index = NULL))
  expect_error(variable$queue_update(values = as.list(rep(NULL, size)), index = NULL))
  expect_error(variable$queue_update(values = as.list(rep(c(NULL, 1), times = c(size-1 ,1))), index = NULL))
  
})


# variable fill (index NULL, values length 1)

test_that("RaggedDouble queue/update works with verifiable input (variable fill)", {
  
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  variable$queue_update(values = as.list(100), index = NULL)
  variable$.update()
  expect_equal(variable$get_values(), as.list(rep(100, size)))
  
})

test_that("RaggedDouble queue/update fails with incorrect input (variable fill)", {
  
  size <- 10
  variable <- RaggedDouble$new(as.list(seq_len(size)))
  
  expect_error(variable$queue_update(values = NULL, index = NULL))
  expect_error(variable$queue_update(values = as.list("5"), index = NULL))
  
})
