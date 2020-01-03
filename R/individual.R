#' Class: Individual
#' Represents an individual in our simulation
#' @export Individual
Individual <- DataClass(
  'Individual',
  c('name', 'states'),

  #' @description
  #' Create a new Individual
  #' @param name is a unique idetifier which is used in the output
  #' $param ... a list of State objects

  initialize = function(name, ...) {
    states <- list(...)
    names <- vapply(states, function(state) { state$name }, character(1))
    if (any(duplicated(names))) {
      stop('No duplicate states allowed')
    }
    private$.name <- name
    private$.states <- states
  },
  print_fields = c('name')
)
Individual$set(
  'public',
  'check_state',
  function(state) {
    names <- vapply(self$states, function(s) { s$name }, character(1))
    state$name %in% names
  }
)

#' Class: State
#' Represents a state for an individual in our simulation
#' @export State
State <- DataClass(
  'State',
  c('name', 'initial_size'),

  #' @description
  #' Create a new State
  #' @param name is a unique idetifier which is used in the output
  #' @param initial_size used to initialise the state at the start of the sim

  initialize = function(name, initial_size) {
    if (initial_size < 0) {
      stop('Invalid size')
    }
    private$.name <- name
    private$.initial_size <- initial_size
  },
  print_fields = c('name', 'initial_size')
)
