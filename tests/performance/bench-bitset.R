#
# bench-bitset.R
#
# Created on Oct 13, 2021
#   Author: Sean L. Wu
#

library(individual)
library(bench)
library(ggplot2)

source("./tests/performance/utils.R")

# limit: max size of bitset
# size: number of elements to be inserted
args_grid <- build_grid(base1 = 10, base2 = 5, powers1 = c(3,5,7))


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

erase_bset$type <- "erase"
erase_bset <- simplify_bench_output(out = erase_bset)

iterate_bset$type <- "iterate"
iterate_bset <- simplify_bench_output(out = iterate_bset)

insert_bset$type <- "insert"
insert_bset <- simplify_bench_output(out = insert_bset)

core_ops_bset <- rbind(erase_bset, iterate_bset, insert_bset)

ggplot(data = core_ops_bset) +
  geom_violin(aes(x = as.factor(size), y = time, color = as.factor(size), fill = as.factor(size))) +
  facet_wrap(. ~ type, scales = "free") +
  ggtitle("Core operations benchmark")


# ------------------------------------------------------------
# benchmark: set operations that do not require 'size' argument
# ------------------------------------------------------------

limit_args_grid <- data.frame(limit = 10^(3:8))

# clear
clear_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    bench::mark(
      min_iterations = 100,
      check = FALSE, 
      filter_gc = TRUE,
      {index$clear()}
    )
  }, 
  .grid = limit_args_grid
) 

clear_bset <- simplify_bench_output(clear_bset)

not_bset <- bench::press(
  {
    index <- individual::Bitset$new(size = limit)$insert(1:limit)
    bench::mark(
      min_iterations = 50,
      check = FALSE, 
      filter_gc = TRUE,
      {index$not(inplace = TRUE)}
    )
  }, 
  .grid = limit_args_grid
) 

not_bset <- simplify_bench_output(out = not_bset)

ggplot(data = clear_bset) +
  geom_violin(aes(x = expression, y = time, color = expression, fill = expression)) +
  facet_wrap(. ~ limit, scales = "free") +
  coord_flip() +
  ggtitle("Clear benchmark")

ggplot(data = not_bset) +
  geom_violin(aes(x = expression, y = time, color = expression, fill = expression)) +
  facet_wrap(. ~ limit, scales = "free") +
  coord_flip() +
  ggtitle("Not benchmark")


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

or_bset$type <- "or"
or_bset <- simplify_bench_output(out = or_bset)

and_bset$type <- "and"
and_bset <- simplify_bench_output(out = and_bset)

xor_bset$type <- "xor"
xor_bset <- simplify_bench_output(out = xor_bset)

set_diff_bset$type <- "set_diff"
set_diff_bset <- simplify_bench_output(out = set_diff_bset)

set_ops_bset <- rbind(or_bset, and_bset, xor_bset, set_diff_bset)

ggplot(data = set_ops_bset) +
  geom_violin(aes(x = as.factor(size), y = time, color = as.factor(size), fill = as.factor(size))) +
  facet_wrap(limit ~ type, scales = "free") +
  coord_flip() +
  ggtitle("Set operations benchmark")


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
      {index$choose(k = size)}
    )
  }, 
  .grid = args_grid
) 

choose_bset <- simplify_bench_output(choose_bset)

ggplot(data = choose_bset) +
  geom_violin(aes(x = as.factor(size), y = time, color = as.factor(size), fill = as.factor(size))) +
  ggtitle("Sampling operations benchmark: choose")

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
  geom_violin(aes(x = as.factor(expression), y = time, color = expression, fill = expression)) +
  facet_wrap(size ~ limit, scales = "free") +
  ggtitle("Sampling operations benchmark: filter")