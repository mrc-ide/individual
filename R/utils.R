vnapply <- function(X, FUN, ...) {
  vapply(X, FUN, ..., numeric(1))
}

vcapply <- function(X, FUN, ...) {
  vapply(X, FUN, ..., character(1))
}
