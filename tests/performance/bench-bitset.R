# benchmark the bitset object in individual
# currently we only benchmark erasure and insertion of elements,
# eventually more (all?) of its functionality will be benchmarked

rm(list = ls()); gc()

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

#' @title Create random bitset
#' @param size the number of set bits
#' @param limit the maximum size of the bitset
create_random_bitset <- function(size, limit) {
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
args_grid <- build_grid(base1 = 10, base2 = 5, powers1 = 5)


#' @title Simplify output of [bench::press] for plotting
#' @description Unnest output to generate histograms or density plots, and remove
#' all runs where any level of garbage collection was executed.
#' @param out output of [bench::press] function
simplify_bench_output <- function(out) {
  out <- tidyr::unnest(out, c(time, gc))
  out <- out[out$gc == "none", ]
  return(out)
}


# ------------------------------------------------------------
# benchmark: core operations
# ------------------------------------------------------------

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

erase_bset <- simplify_bench_output(out = erase_bset)

ggplot(data = erase_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

iterate_bset <- simplify_bench_output(out = iterate_bset)

ggplot(data = iterate_bset) +
  geom_violin(aes(x = as.factor(size), y = time))

insert_bset <- simplify_bench_output(out = insert_bset)

ggplot(data = insert_bset) +
  geom_violin(aes(x = as.factor(size), y = time))


# ------------------------------------------------------------
# benchmark: set operations
# ------------------------------------------------------------

or_bset <- bench::press(
  {
    index1 <- create_random_bitset(size = size, limit = limit)
    index2 <- create_random_bitset(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index1$or(index2)},
    )
  }, 
  .grid = args_grid
) 

and_bset <- bench::press(
  {
    index1 <- create_random_bitset(size = size, limit = limit)
    index2 <- create_random_bitset(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index1$and(index2)},
    )
  }, 
  .grid = args_grid
) 

not_bset <- bench::press(
  {
    index <- create_random_bitset(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$not(inplace = TRUE)},
    )
  }, 
  .grid = args_grid
) 

xor_bset <- bench::press(
  {
    index1 <- create_random_bitset(size = size, limit = limit)
    index2 <- create_random_bitset(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index1$xor(index2)},
    )
  }, 
  .grid = args_grid
) 

set_diff_bset <- bench::press(
  {
    index1 <- create_random_bitset(size = size, limit = limit)
    index2 <- create_random_bitset(size = size, limit = limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index1$set_difference(index2)},
    )
  }, 
  .grid = args_grid
)

or_bset <- simplify_bench_output(out = or_bset)
and_bset <- simplify_bench_output(out = and_bset)
not_bset <- simplify_bench_output(out = not_bset)
xor_bset <- simplify_bench_output(out = xor_bset)
set_diff_bset <- simplify_bench_output(out = set_diff_bset)

set_ops_bset <- rbind(or_bset, and_bset, not_bset, xor_bset, set_diff_bset)

ggplot(data = set_ops_bset) +
  geom_violin(aes(x = as.factor(size), y = time, color = as.factor(size), fill = as.factor(size))) +
  facet_wrap(. ~ expression, scales = "free")


# ------------------------------------------------------------
# benchmark: sampling operations
# ------------------------------------------------------------

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

choose_bset <- simplify_bench_output(choose_bset)

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

filter_bset <- simplify_bench_output(filter_bset)

ggplot(data = filter_bset) +
  geom_violin(aes(x = expression, y = time, color = expression, fill = expression)) +
  facet_wrap(size ~ limit, scales = "free")
