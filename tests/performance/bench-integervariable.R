#
# bench-integervariable.R
#
# Created on Oct 13, 2021
#   Author: Sean L. Wu
#

library(individual)
library(bench)
library(ggplot2)

source("./tests/performance/utils.R")

# base1 is for maximal population size
# base2 is for the updating size
# n is the number of updates that are queued
args_grid <- build_grid(base1 = 10, base2 = 5, powers1 = c(3, 5), n = 3)


# ------------------------------------------------------------
# benchmark: queue and apply updates
# ------------------------------------------------------------

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
  .grid = args_grid
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
  .grid = args_grid
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
  .grid = args_grid
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
  .grid = args_grid
)

update_sv_bi$type <- "sv-bi"
update_vv_bi$type <- "vv-bi"
update_sv_vi$type <- "sv-vi"
update_vv_vi$type <- "vv-vi"

update_sv_bi <- simplify_bench_output(update_sv_bi)
update_vv_bi <- simplify_bench_output(update_vv_bi)
update_sv_vi <- simplify_bench_output(update_sv_vi)
update_vv_vi <- simplify_bench_output(update_vv_vi)

update_all <- rbind(update_sv_bi, update_vv_bi, update_sv_vi, update_vv_vi)

ggplot(data = update_all) +
  geom_violin(aes(type, time, fill = type, color = type)) +
  facet_wrap(limit ~ size, scales = "free", labeller = label_context) +
  ggtitle("Integer variable benchmark")
              