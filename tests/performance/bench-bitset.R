# benchmark the bitset object in individual
# currently we only benchmark erasure and insertion of elements,
# eventually more (all?) of its functionality will be benchmarked

library(individual)
library(bench)
library(ggplot2)
library(tidyr)

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

# core operations

# limit: max size of bitset
# size: number of elements to be inserted
args_grid <- build_grid(base1 = 10, base2 = 5, powers1 = 5)

insert_bset <- bench::press(
 {
    index <- individual::Bitset$new(size = limit)
    data <- create_random_data(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$insert(data)}
    )
  }, 
 .grid = args_grid
)

# iteration: use to_vector
iterate_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)
    data <- create_random_data(size = size, limit = limit)
    index$insert(data)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$to_vector()}
    )
  }, 
  .grid = args_grid
)

# erase
erase_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    data <- create_random_data(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$remove(data)}
    )
  }, 
  .grid = args_grid
)

erase_bset <- tidyr::unnest(erase_bset, c(time, gc))
erase_bset <- erase_bset[erase_bset$gc == "none", ]

ggplot(data = erase_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

iterate_bset <- tidyr::unnest(iterate_bset, c(time, gc))
iterate_bset <- iterate_bset[iterate_bset$gc == "none", ]

ggplot(data = iterate_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

insert_bset <- tidyr::unnest(insert_bset, c(time, gc))
insert_bset <- insert_bset[insert_bset$gc == "none", ]

ggplot(data = insert_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

# set operations
# or_bset
# and_bset
# not_bset
# xor_bset
# set_diff_bset

# sampling operations
# sample_bset

choose_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$choose(k = size)},
    )
  }, 
  .grid = args_grid
) 

choose_bset <- tidyr::unnest(choose_bset, c(time, gc))
choose_bset <- choose_bset[choose_bset$gc == "none", ]

ggplot(data = choose_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

filter_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    vector_idx <- create_random_data(size = size, limit = limit)
    bset_idx <- individual::Bitset$new(size = limit)$insert(vector_idx)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      vector = {individual::filter_bitset(bitset = index, other = vector_idx)},
      bset = {individual::filter_bitset(bitset = index, other = bset_idx)}
    )
  }, 
  .grid = args_grid
) 

filter_bset <- tidyr::unnest(filter_bset, c(time, gc))
filter_bset <- filter_bset[filter_bset$gc == "none", ]

ggplot(data = filter_bset) +
  geom_violin(aes(x = expression, y = time, color = expression, fill = expression)) +
  facet_wrap(size ~ limit, scales = "free")
