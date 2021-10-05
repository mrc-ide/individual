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