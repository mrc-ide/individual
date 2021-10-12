# need to check queueing updates and applying updates for:
# single value, bitset index
# many values bitset index
# single value, vector index
# many values, vector index

library(individual)
library(bench)
library(ggplot2)
library(tidyr)

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
test_grid <- build_grid_2base(base1 = 10, base2 = 5, powers1 = c(3, 5), n = 3)


# single value, bitset index
update_sv_bi <- bench::press(
  {
    variable <- individual::IntegerVariable$new(initial_values = rep(1L, limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)
    })
    value <- 0L
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(values = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = test_grid
)

# vector value, bitset index
update_vv_bi <- bench::press(
  {
    variable <- individual::IntegerVariable$new(initial_values = rep(1L, limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)
    })
    value <- rep(0L, size)
    bench::mark(
      min_iterations = 50,
      check = FALSE,
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(values = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = test_grid
)

# single value, vector index
update_sv_vi <- bench::press(
  {
    variable <- individual::IntegerVariable$new(initial_values = rep(1L, limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)$to_vector()
    })
    value <- 0L
    bench::mark(
      min_iterations = 50,
      check = FALSE,
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(values = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = test_grid
)

# vector value, vector index
update_vv_vi <- bench::press(
  {
    variable <- individual::IntegerVariable$new(initial_values = rep(1L, limit))
    indices <- lapply(X = 1:n, FUN = function(nn){
      create_random_index_bitset(size = size, limit = limit)$to_vector()
    })
    value <- rep(0L, size)
    bench::mark(
      min_iterations = 50,
      check = FALSE,
      filter_gc = TRUE,
      {
        lapply(X = indices, FUN = function(b){
          variable$queue_update(values = value, index = b)
        })
        variable$.update()
      }
    )
  }, 
  .grid = test_grid
)

update_sv_bi$type <- "sv-bi"
update_vv_bi$type <- "vv-bi"
update_sv_vi$type <- "sv-vi"
update_vv_vi$type <- "vv-vi"

update_sv_bi <- tidyr::unnest(update_sv_bi, c(time, gc))
update_vv_bi <- tidyr::unnest(update_vv_bi, c(time, gc))
update_sv_vi <- tidyr::unnest(update_sv_vi, c(time, gc))
update_vv_vi <- tidyr::unnest(update_vv_vi, c(time, gc))

update_all <- rbind(update_sv_bi, update_vv_bi, update_sv_vi, update_vv_vi)
update_all <- update_all[update_all$gc == "none", ]

ggplot(data = update_all) +
  geom_violin(aes(type, time, fill = type, color = type)) +
  facet_wrap(limit ~ size, scales = "free", labeller = label_context)
              