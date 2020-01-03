#' Sorts a simulation by timestep and state making it comparable to others
#' @param simulation to sort
sort_simulation <- function(a) {
  a[order(
    slice.index(a, 3), #timestep
    a                  #state
  )]
}
