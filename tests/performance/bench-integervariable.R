# need to check queueing updates and applying updates for:
# single value, bitset index
# many values bitset index
# single value, vector index
# many values, vector index

# for each we want to run multiple times and apply the update.
# each time we can use random indices.

#' @title Create random integer vector
#' @param size the size of the vector to be produced
#' @param limit random elements will be between 1 and limit
create_random_index_vector <- function(size, limit) {
  stopifnot(is.finite(size))
  stopifnot(is.finite(limit))
  stopifnot(limit > 0)
  sample.int(n = limit, size = size, replace = FALSE)
}

#' @title Create random bitset
#' @param size the number of set elements in the bitset
#' @param limit maximum size of the bitset
create_random_index_bitset <- function(size, limit) {
  stopifnot(is.finite(size))
  stopifnot(is.finite(limit))
  stopifnot(limit > 0)
  bset <- individual::Bitset$new(size = limit)
  bset$not(inplace = TRUE)
  bset$choose(k = size)
  return(bset)
}

#' @title Create grid of parameters for benchmarking
#' @param base1 the base of the first (major) sequence
#' @param base2 the base of the second (minor) sequence, should be less than `base1`
#' @param powers1 the sequence of powers for the first sequence, should not include powers < 1
#' @param n the number of times to run each combination
build_grid <- function(base1, base2, powers1, n) {
  stopifnot(base2 < base1)
  stopifnot(min(powers1) > 1)
  
  grid <- lapply(X = powers1, FUN = function(x) {
    lim <- base1^x
    y <- floor(log(base1^x) / log(base2))
    size_seq <- base2^(1:y)
    data.frame("limit" = lim, "size" = size_seq, "n" = as.integer(n))
  })
  do.call(what = rbind, args = grid)
}


# base1 is for maximal population size
# base2 is for the updating size
# n is the number of updates that are queued
test_grid <- build_grid(base1 = 10, base2 = 4, powers1 = c(5), n = 3)


# single value, bitset index
update_1 <- bench::press(
  {
    variable <- individual::IntegerVariable$new(initial_values = rep(1L, limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)
    })
    value <- 0L
    bench::mark(
      min_iterations = 10,
      BM_update = {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(values = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = test_grid
)

