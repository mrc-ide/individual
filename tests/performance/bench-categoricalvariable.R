library(individual)
library(bench)
library(ggplot2)
library(tidyr)

# for each we want to run multiple times and apply the update.
# each time we can use random indices.

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

#' @title Simplify output of [bench::press] for plotting
#' @description Unnest output to generate histograms or density plots, and remove
#' all runs where any level of garbage collection was executed.
#' @param out output of [bench::press] function
simplify_bench_output <- function(out) {
  out <- tidyr::unnest(out, c(time, gc))
  out <- out[out$gc == "none", ]
  return(out)
}

#' @title Create grid of parameters for benchmarking
#' @description First, construct a grid of values raising `base1` to powers in
#' `powers1` (the major sequence).
#' @param base1 the base of the first (major) sequence
#' @param base2 the base of the second (minor) sequence, should be less than `base1`
#' @param powers1 the sequence of powers for the first sequence, should not include powers < 1
#' @param n the number of times to run each combination, or extra integer argument.
build_grid_2base <- function(base1, base2, powers1, n) {
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
args_grid <- build_grid_2base(base1 = 10, base2 = 5, powers1 = c(3, 5), n = 3)


# ------------------------------------------------------------
# benchmark: queue and apply updates
# ------------------------------------------------------------

update_bset <- bench::press(
  {
    variable <- individual::CategoricalVariable$new(categories = LETTERS[1:2], initial_values = rep(LETTERS[1], times = limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)
    })
    value <- LETTERS[2]
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(value = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = args_grid
)

update_vector <- bench::press(
  {
    variable <- individual::CategoricalVariable$new(categories = LETTERS[1:2], initial_values = rep(LETTERS[1], times = limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)$to_vector()
    })
    value <- LETTERS[2]
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(value = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = args_grid
)


update_bset$type <- "bset"
update_vector$type <- "vector"

update_bset <- simplify_bench_output(update_bset)
update_vector <- simplify_bench_output(update_vector)

update_all <- rbind(update_bset, update_vector)

ggplot(data = update_all) +
  geom_violin(aes(type, time, fill = type, color = type)) +
  facet_wrap(limit ~ size, scales = "free", labeller = label_context)

