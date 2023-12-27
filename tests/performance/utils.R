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

#' @title Simplify output of [bench::press] for plotting
#' @description Unnest output to generate histograms or density plots, and remove
#' all runs where any level of garbage collection was executed.
#' @param out output of [bench::press] function
simplify_bench_output <- function(out, filter_gc=TRUE) {
  x <- lapply(X = seq_len(nrow(out)), FUN = function(i) {
    # get gc level (if run) as factor
    gc <- rep("none", times = nrow(out$gc[[i]]))
    gc[which(out$gc[[i]][["level0"]] != 0)] <- "level0"
    gc[which(out$gc[[i]][["level1"]] != 0)] <- "level1"
    gc[which(out$gc[[i]][["level2"]] != 0)] <- "level2"
    gc <- factor(x = gc, levels = c("none", "level0", "level1", "level2"), ordered = FALSE)
    # time
    time <- out$time[[i]]
    # replicate rows
    n <- length(time)
    out_i <- out[rep(i, times = n), which(!(colnames(out) %in% c("result", "memory", "time", "gc")))]
    out_i$time <- time
    out_i$gc <- gc
    return(out_i)
  })
  out_format <- do.call(what = rbind, args = x)
  if (filter_gc)
  {
    out_format <- out_format[out_format$gc == "none", ]
  }
  out_format$expression <- as.factor(attr(out_format$expression, "description"))
  return(out_format)
}

#' @title Create grid of parameters for benchmarking
#' @param base1 the base of the first (major) sequence
#' @param base2 the base of the second (minor) sequence, should be less than `base1`
#' @param powers1 the sequence of powers for the first sequence, should not include powers < 1
build_grid <- function(base1, base2, powers1, n = NULL) {
  stopifnot(base2 < base1)
  stopifnot(min(powers1) > 1)
  
  grid <- lapply(X = powers1, FUN = function(x) {
    lim <- base1^x
    y <- floor(log(base1^x) / log(base2))
    size_seq <- base2^(1:y)
    data.frame("limit" = lim, "size" = size_seq)
  })
  out <- do.call(what = rbind, args = grid)
  if (!is.null(n)) {
    out$n <- as.integer(n)
  }
  return(out)
}
