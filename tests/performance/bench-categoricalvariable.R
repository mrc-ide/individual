#
# bench-categoricalvariable.R
#
# Created on Oct 18, 2021
#   Author: Sean L. Wu
#

library(individual)
library(bench)
library(ggplot2)

source("./tests/performance/utils.R")

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

