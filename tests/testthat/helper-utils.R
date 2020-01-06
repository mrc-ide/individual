#' Sorts a simulation by timestep and state making it comparable to others
#' @param simulation to sort
sort_simulation_states <- function(a) {
  a[order(
    slice.index(a, 2), #timestep
    a                  #state
  )]
}
