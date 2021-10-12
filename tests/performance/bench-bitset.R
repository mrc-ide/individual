#' @title Create random integer vector
#' @param size the size of the vector to be produced
#' @param limit random elements will be between 1 and limit
create_random_data <- function(size, limit) {
  stopifnot(is.finite(size))
  stopifnot(is.finite(limit))
  stopifnot(limit > 0)
  sample.int(n = limit, size = size, replace = FALSE)
}

#' @title Create grid of parameters for benchmarking
#' @param base1 the base of the first (major) sequence
#' @param base2 the base of the second (minor) sequence, should be less than `base1`
#' @param powers1 the sequence of powers for the first sequence, should not include powers < 1
build_grid <- function(base1, base2, powers1) {
  stopifnot(base2 < base1)
  stopifnot(min(powers1) > 1)
  
  grid <- lapply(X = powers1, FUN = function(x) {
    lim <- base1^x
    y <- floor(log(base1^x) / log(base2))
    size_seq <- base2^(1:y)
    data.frame("limit" = lim, "size" = size_seq)
  })
  do.call(what = rbind, args = grid)
}

# limit: max size of bitset
# size: number of elements to be inserted
insert_index_grid <- build_grid(base1 = 10, base2 = 2, powers1 = 5)

insert_bset <- bench::press(
 {
    index <- individual::Bitset$new(size = limit)
    data <- create_random_data(size = size, limit = limit)
    bench::mark(
      min_iterations = 10,
      BM_insert_index = index$insert(data)
    )
  }, 
 .grid = insert_index_grid
)


# erase
erase_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    data <- create_random_data(size = size, limit = limit)
    bench::mark(
      min_iterations = 10,
      BM_insert_index = index$remove(data)
    )
  }, 
  .grid = insert_index_grid
)
