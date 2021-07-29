test_that("updating variables works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  first <- sequence$get_values()
  sequence$queue_update((1:5) * 2, 1:5)
  sequence$.update()
  middle <- sequence$get_values()
  sequence$queue_update(11, 2:6)
  sequence$.update()
  last <- sequence$get_values()

  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
})

test_that("updating variables at the boundaries works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(2, 10)
  sequence$queue_update(2, 1)
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, c(2, 2:9, 2))
})

test_that("updating variables with an empty index is ignored", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(11, numeric(0))
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 1:10)
})

test_that("updating variables with an empty bitset is ignored", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(11, Bitset$new(10))
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 1:10)
})

test_that("updating variables with silly indices errors gracefully", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  # different sized values and index
  expect_error(sequence$queue_update(c(1.0, 2.0), 1:5))

  expect_error(sequence$queue_update(11, -1:3)) # invalid index

  expect_error(sequence$queue_update(11, 9:15)) # out of bounds
})

test_that("Queuing non numeric values errors gracefully", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))
  expect_error(sequence$queue_update(c(1, "A"), 1:2))
})

test_that("updating the complete variable vector works", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  before <- sequence$get_values()

  sequence$queue_update(11:20)
  sequence$.update()

  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 11:20)
})

test_that("Vector fill variable updates work", {
  size <- 10
  sequence <- DoubleVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(14)
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, rep(14, 10))
})

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


test_that("updating IntegerVariable works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  first <- sequence$get_values()
  sequence$queue_update((1:5) * 2, 1:5)
  sequence$.update()
  middle <- sequence$get_values()
  sequence$queue_update(11, 2:6)
  sequence$.update()
  last <- sequence$get_values()

  expect_equal(first, 1:10)
  expect_equal(middle, c((1:5) * 2, 6:10))
  expect_equal(last, c(2, rep(11, 5), 7:10))
})

test_that("updating IntegerVariable at the boundaries works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(2, 10)
  sequence$queue_update(2, 1)
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, c(2, 2:9, 2))
})

test_that("updating IntegerVariable with an empty index is ignored", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(11, numeric(0))
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 1:10)
})

test_that("updating IntegerVariable with silly indices errors gracefully", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  # different sized values and index
  expect_error(sequence$queue_update(c(1.0, 2.0), 1:5))

  expect_error(sequence$queue_update(11, -1:3)) # invalid index

  expect_error(sequence$queue_update(11, 9:15)) # out of bounds
})

test_that("Queuing non numeric value for IntgerVariable errors gracefully", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))
  expect_error(sequence$queue_update(c(1, "A"), 1:2))
})

test_that("updating the complete IntegerVariable vector works", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  before <- sequence$get_values()

  sequence$queue_update(11:20)
  sequence$.update()

  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 11:20)
})

test_that("Vector fill IntegerVariable updates work", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(14)
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, rep(14, 10))
})

test_that("updating IntegerVariable with an empty bitset is ignored", {
  size <- 10
  sequence <- IntegerVariable$new(seq_len(size))

  before <- sequence$get_values()
  sequence$queue_update(11, Bitset$new(10))
  sequence$.update()
  after <- sequence$get_values()

  expect_equal(before, 1:10)
  expect_equal(after, 1:10)
})

