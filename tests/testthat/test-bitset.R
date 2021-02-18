test_that("bitset insertions and removals work", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  expect_equal(a$to_vector(), c(1, 5, 6))
  a$remove(c(5, 6))
  expect_equal(a$to_vector(), 1)
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