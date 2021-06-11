test_that("bitset insertions and removals work", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  expect_equal(a$to_vector(), c(1, 5, 6))
  a$remove(c(5, 6))
  expect_equal(a$to_vector(), 1)
})

test_that("out of range inserts don't work", {
  a <- Bitset$new(10)
  expect_error(
    a$insert(9:15),
    '*'
  )
})

test_that("bitset size updates", {
  a <- Bitset$new(10)
  expect_equal(a$max_size, 10)
  expect_equal(a$size(), 0)
  a$insert(c(1, 5, 6))
  expect_equal(a$size(), 3)
  a$remove(c(5, 6))
  expect_equal(a$size(), 1)
})

test_that("bitset and works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  b <- Bitset$new(10)
  b$insert(c(1, 3, 7))
  a$and(b)
  expect_equal(a$to_vector(), 1)
})

test_that("bitset or works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  b <- Bitset$new(10)
  b$insert(c(1, 3, 7))
  a$or(b)
  expect_equal(a$to_vector(), c(1, 3, 5, 6, 7))
})

test_that("bitset set difference works for sets with intersection", {
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 7:15
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  expect_equal(
    a$to_vector(), setdiff(a0,b0)
  )
})

test_that("bitset set difference works for disjoint sets", {
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 15:20
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  expect_equal(
    a$to_vector(), setdiff(a0,b0)
  )
})

test_that("bitset set difference works for identical sets", {
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 1:10
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  expect_length(
    a$to_vector(), 0
  )
})

test_that("bitset xor works for identical sets", {
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 1:10
  a$insert(a0)
  b$insert(b0)
  a$xor(b)
  expect_length(
    a$to_vector(), 0
  )
})

test_that("bitset xor works for sets with intersection", {
  sym_diff <- function(a,b) {setdiff(union(a,b), intersect(a,b))}
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:7
  b0 <- 5:10
  a$insert(a0)
  b$insert(b0)
  a$xor(b)
  expect_equal(
    a$to_vector(), sym_diff(a0,b0)
  )
})

test_that("bitset xor works for disjoint sets", {
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:5
  b0 <- 6:10
  a$insert(a0)
  b$insert(b0)
  a$xor(b)
  expect_equal(
    a$to_vector(), 1:10
  )
})


test_that("bitset combinations work", {
  a <- Bitset$new(10)$not()
  b <- Bitset$new(10)
  expect_equal(a$or(b)$to_vector(), seq(10))
})

test_that("multi-word bitset combinations work", {
  a <- Bitset$new(100)$not()
  b <- Bitset$new(100)
  expect_equal(a$or(b)$to_vector(), seq(100))
})

test_that("bitset inverse works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  expect_equal(a$not()$to_vector(), c(2, 3, 4, 7, 8, 9, 10))
  expect_equal(a$not()$size(), 7)
})

test_that("bitset sample works at rate = 0", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  a$sample(0)
  expect_equal(a$size(), 0)
})

test_that("bitset sample works at rate = 1", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  a$sample(1)
  expect_equal(a$to_vector(), c(1, 5, 6))
})

test_that("bitset filtering works for vectors", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- c(1, 3)
  expect_equal(filter_bitset(b, f)$to_vector(), c(1, 6))
})

test_that("bitset filtering works for bitsets", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- Bitset$new(10)$insert(c(1, 3))
  expect_equal(filter_bitset(b, f)$to_vector(), c(1, 6))
})

test_that("bitset throws error when given bad input probabilities in sample", {
  b <- Bitset$new(10)$insert(1:10)
  expect_error(
    b$sample(rate = c(rep(0.1,9),NA))
  )
})
