#' @title Create random integer vector
#' @param size the size of the vector to be produced
#' @param limit random elements will be between 1 and limit
create_random_data <- function(size, limit) {
  stopifnot(is.finite(size))
  stopifnot(is.finite(limit))
  stopifnot(limit > 0)
  stopifnot(size > limit)
  sample.int(n = limit, size = size, replace = FALSE)
}


# limit: max size of bitset
# size: number of elements to be inserted
insert_index_grid

limit_powers <- 1:7
limit_seq <- 10^limit_powers

insert_index_grid <- lapply(X = limit_powers, FUN = function(x) {
  lim <- 10^x
  y <- floor(log(10^x) / log(2))
  size_seq <- 2^(0:y)
  data.frame("limit" = lim, "size" = size_seq)
})
insert_index_grid <- do.call(what = rbind, args = insert_index_grid)

insert_index <- bench::press(
 {
    
  }, 
 .grid = 
)

results <- bench::press(
  rows = c(1000, 10000),
  cols = c(2, 10),
  {
    dat <- create_df(rows, cols)
    bench::mark(
      min_iterations = 100,
      bracket = dat[dat$x > 500, ],
      which = dat[which(dat$x > 500), ],
      subset = subset(dat, x > 500)
    )
  }
)