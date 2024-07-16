test_that("bitset insertions and removals work", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  expect_equal(a$to_vector(), c(1, 5, 6))
  a$remove(c(5, 6))
  expect_equal(a$to_vector(), 1)
})

test_that("bitset clear works", {
  b <- Bitset$new(0)
  expect_equal(b$clear()$size(), 0)
  expect_equal(b$clear()$to_vector(), numeric(0))
  
  b <- Bitset$new(10)
  expect_equal(b$clear()$size(), 0)
  expect_equal(b$clear()$to_vector(), numeric(0))
  
  b$insert(1:10)$clear()
  expect_equal(b$size(), 0)
  expect_equal(b$to_vector(), numeric(0))
  
  b$insert(c(1, 5, 10))$clear()
  expect_equal(b$size(), 0)
  expect_equal(b$to_vector(), numeric(0))
  
  a <- Bitset$new(10)$insert(1:10)
  expect_equal(a$size(), 10)
  expect_equal(a$to_vector(), 1:10)
  a$and(b)
  expect_equal(a$size(), 0)
  expect_equal(a$to_vector(), numeric(0))
  
  b$insert(1:3)
  expect_equal(b$to_vector(), 1:3)
})


test_that("out of range inserts don't work", {
  a <- Bitset$new(10)
  expect_error(
    a$insert(9:15),
    '*'
  )
})

test_that("bitset copy works", {
  a <- Bitset$new(10)$insert(1:5)
  b <- a$copy()
  b$not(inplace = TRUE)
  
  expect_equal(a$to_vector(), 1:5)
  expect_equal(b$to_vector(), 6:10)
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

test_that("bitset copy from works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  b <- Bitset$new(10)
  b$insert(c(1, 3, 7))

  a$copy_from(b)
  expect_equal(a$to_vector(), c(1, 3, 7))

  # Check the two bitsets aren't aliases of each other.
  b$clear()
  expect_equal(a$to_vector(), c(1, 3, 7))
  expect_equal(b$to_vector(), numeric(0))
})

test_that("bitset copy from requires bitsets to have same max size", {
  a <- Bitset$new(8)
  a$insert(c(1, 5, 6))
  b <- Bitset$new(10)
  b$insert(c(1, 3, 7))

  expect_error(a$copy_from(b), "Incompatible bitmap sizes")
})


test_that("bitset set difference works for sets with intersection", {
  
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 7:15
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  
  expect_equal(a$to_vector(), setdiff(a0,b0))
  expect_equal(b$to_vector(), b0)
})

test_that("bitset set difference works for disjoint sets", {
  
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 15:20
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  
  expect_equal(a$to_vector(), setdiff(a0,b0))
  expect_equal(b$to_vector(), b0)
})

test_that("bitset set difference works for identical sets", {
  
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 1:10
  a$insert(a0)
  b$insert(b0)
  a$set_difference(b)
  
  expect_length(a$to_vector(), 0)
  expect_equal(b$to_vector(), b0)
})

test_that("bitset xor works for identical sets", {
  
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:10
  b0 <- 1:10
  a$insert(a0)
  b$insert(b0)
  a$xor(b)
  
  expect_length(a$to_vector(), 0)
  expect_equal(b$to_vector(), b0)
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
  
  expect_equal(a$to_vector(), sym_diff(a0,b0))
  expect_equal(b$to_vector(), b0)
})

test_that("bitset xor works for disjoint sets", {
  
  a <- Bitset$new(20)
  b <- Bitset$new(20)
  a0 <- 1:5
  b0 <- 6:10
  a$insert(a0)
  b$insert(b0)
  a$xor(b)
  
  expect_equal(a$to_vector(), 1:10)
  expect_equal(b$to_vector(), b0)
})


test_that("bitset combinations work", {
  a <- Bitset$new(10)$not(FALSE)
  b <- Bitset$new(10)
  expect_equal(a$or(b)$to_vector(), seq(10))
})

test_that("multi-word bitset combinations work", {
  a <- Bitset$new(100)$not(FALSE)
  b <- Bitset$new(100)
  expect_equal(a$or(b)$to_vector(), seq(100))
})

test_that("bitset inverse works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  expect_equal(a$not(FALSE)$to_vector(), c(2, 3, 4, 7, 8, 9, 10))
  expect_equal(a$not(TRUE)$size(), 7)
})

test_that("bitset not inplace switch works", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  b <- a
  a$not(TRUE)
  expect_equal(b$to_vector(), c(2, 3, 4, 7, 8, 9, 10))
  b <- b$not(FALSE)
  expect_equal(a$to_vector(), c(2, 3, 4, 7, 8, 9, 10))
  expect_equal(b$to_vector(), c(1, 5, 6))
})

# bitset sampling

test_that("bitset sample works with correct input", {
  a <- Bitset$new(10)
  
  a$insert(c(1, 5, 6))
  a$sample(0)
  expect_equal(a$size(), 0)
  
  a$insert(c(1, 5, 6))
  a$sample(1)
  expect_equal(a$to_vector(), c(1, 5, 6))
  
  a$insert(1:10)
  a$sample(rep(x = c(0, 1), times = c(5, 5)))
  expect_equal(a$to_vector(), 6:10)
})

test_that("bitset sample fails with incorrect input", {
  a <- Bitset$new(10)
  a$insert(c(1, 5, 6))
  
  expect_error(a$sample(NaN))
  expect_error(a$sample(NULL))
  expect_error(a$sample(NA))
  expect_error(a$sample(Inf))
  expect_error(a$sample(-Inf))
  expect_error(a$sample("1"))
  
  expect_error(a$sample(rep(NaN, 10)))
  expect_error(a$sample(rep(NULL, 10)))
  expect_error(a$sample(rep(NA, 10)))
  expect_error(a$sample(rep(Inf, 10)))
  expect_error(a$sample(rep(-Inf, 10)))
  expect_error(a$sample(rep("1", 10)))
  
  expect_error(a$sample(rep(c(0.5, NaN), times = c(1, 9))))
  expect_error(a$sample(rep(c(0.5, NULL), times = c(1, 9))))
  expect_error(a$sample(rep(c(0.5, NA), times = c(1, 9))))
  expect_error(a$sample(rep(c(0.5, Inf), times = c(1, 9))))
  expect_error(a$sample(rep(c(0.5, -Inf), times = c(1, 9))))
})

# bitset choose

test_that("bitset choose works with correct input", {
  b <- Bitset$new(10)$insert(1:8)
  expect_equal(b$copy()$or(b$copy()$choose(5))$to_vector(), b$to_vector()) # check that b$choose is a subset of b
  
  b <- Bitset$new(10)$insert(1:8)
  expect_equal(b$choose(5)$size(), 5)
  
  b <- Bitset$new(10)$insert(1:8)
  expect_equal(b$choose(0)$size(), 0)
  
  b <- Bitset$new(10)$insert(1:8)
  expect_equal(b$choose(8)$size(), 8)
})


test_that("bitset choose errors with incorrect input", {
  b <- Bitset$new(10)
  expect_error(b$choose(5))
  expect_error(b$choose(-1))
  expect_error(b$choose(100))
  expect_error(b$choose(Inf))
  expect_error(b$choose(-Inf))
  expect_error(b$choose(NA))
  expect_error(b$choose(NULL))
  expect_error(b$choose(NaN))
  
  b <- Bitset$new(10)$insert(1:8)
  expect_error(b$choose(10))
})

# bitset filter
test_that("bitset filtering works for NULL", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- numeric(0)
  expect_equal(filter_bitset(b, f)$to_vector(), numeric(0))
})

test_that("bitset filtering works for one element", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- 2
  expect_equal(filter_bitset(b, f)$to_vector(), 5)
})

test_that("bitset filtering works for vector input", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- c(1, 3)
  expect_equal(filter_bitset(b, f)$to_vector(), c(1, 6))
})

test_that("bitset filtering works for logical input", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- c(TRUE, FALSE, TRUE)
  expect_equal(filter_bitset(b, f)$to_vector(), c(1, 6))
})

test_that("bitset filtering errors when logical vector is too short", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- c(TRUE, FALSE)
  expect_error(
    filter_bitset(b, f),
    "vector of logicals must equal the size of the bitset")
})

test_that("bitset filtering works for vector input with jump at the start", {
  b <- Bitset$new(10)$insert(c(1, 5, 6, 10))
  f <- c(2, 4)
  expect_equal(filter_bitset(b, f)$to_vector(), c(5, 10))
})

test_that("bitset filtering works for bitset input", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- Bitset$new(10)$insert(c(1, 3))
  expect_equal(filter_bitset(b, f)$to_vector(), c(1, 6))
})

test_that("bitset filtering works when given empty vector", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- integer(0)
  expect_equal(filter_bitset(b, f)$size(), 0)
  expect_equal(filter_bitset(b, integer(0))$size(), 0)
})

test_that("bitset filtering works when given empty bitset", {
  b <- Bitset$new(10)$insert(c(1, 5, 6))
  f <- Bitset$new(10)
  expect_equal(filter_bitset(b, f)$size(), 0)
  expect_equal(filter_bitset(b, integer(0))$size(), 0)
})

test_that("bitset sampling with extremes is correct", {
  size <- 100
  expect_equal(Bitset$new(size)$not()$sample(0)$size(), 0)
  expect_equal(Bitset$new(size)$not()$sample(1)$size(), size)
})

test_that("bitset is evenly sampled", {
  set.seed(123)

  threshold <- 0.05
  rates <- c(0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99)
  size <- 100
  N <- 1000

  for (rate in rates) {
    freqs <- rep(0, size)
    for (i in seq(N)) {
      b <- Bitset$new(size)$not()$sample(rate)
      xs <- b$to_vector()
      freqs[xs] <- freqs[xs] + 1
    }
    p <- chisq.test(freqs)$p.value
    expect_gt(p, threshold)
  }
})

test_that("bitset sampling has correctly distributed size", {
  set.seed(123)

  threshold <- 0.05
  rates <- c(0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99)
  size <- 100
  N <- 1000

  for (rate in rates) {
    data <- sapply(1:N, function(i) {
      Bitset$new(size)$not()$sample(rate)$size()
    })
    p <- t.test(data, mu=rate*size)$p.value
    expect_gt(p, threshold)
  }
})

test_that("bitset equality works", {
  a <- Bitset$new(10)
  b <- Bitset$new(10)
  c <- Bitset$new(10)
  d <- Bitset$new(10)
  e <- Bitset$new(10)
  f <- Bitset$new(10)

  c$insert(c(1, 2, 3))
  d$insert(c(1, 2, 3))
  e$insert(c(4, 5, 6))
  f$insert(c(4, 7))

  expect_equal(a, b)
  expect_equal(c, d)

  expect_false(isTRUE(all.equal(a, c)))
  expect_false(isTRUE(all.equal(a, e)))
  expect_false(isTRUE(all.equal(a, f)))
  expect_false(isTRUE(all.equal(c, e)))
  expect_false(isTRUE(all.equal(c, f)))
  expect_false(isTRUE(all.equal(e, f)))

  expect_equal(a, a$copy())
  expect_equal(c, c$copy())
  expect_equal(e, e$copy())
  expect_equal(f, f$copy())
})

test_that("bitsets with different capacities are not equal", {
  a <- Bitset$new(10)
  b <- Bitset$new(11)
  expect_match(all.equal(a, b), "Bitset capacity differs")
})

test_that("bitset is not equal to other types", {
  a <- Bitset$new(10)
  a$insert(c(1,4,5))
  expect_equal(all.equal(a, c(1,4,5)), "'current' is not a Bitset")
})
