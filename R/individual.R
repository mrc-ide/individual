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

#' Class: Variable
#' Represents a variable for an individual in our simulation
#' @export Variable
Variable <- DataClass(
  'Variable',
  c('name', 'initialiser', 'updater', 'interval'),

  #' @description
  #' Create a new State
  #' @param name is a unique idetifier which is used in the output
  #' @param initialiser a function used to initialise the variable at the start
  #' of the simulation. The initialiser function takes the population size as
  #' its only argument
  #' @param updater is an update function used to update the variable.
  #' updater functions take the value of the variable at the previous timestep
  #' and the current timestep as arguments

  initialize = function(name, initialiser, updater = NULL, interval = 1) {
    if (interval < 1) {
      stop('Invalid interval')
    }
    private$.name <- name
    private$.initialiser <- initialiser
    private$.updater <- updater
    private$.interval <- interval
  },
  print_fields = c('name', 'interval')
)

#' Class: Constant
#' Represents a constant for an individual in our simulation
#' @export Constant
Constant <- DataClass(
  'Constant',
  c('name', 'initialiser'),

  #' @description
  #' Create a new State
  #' @param name is a unique idetifier which is used in the output
  #' @param initialiser a function used to initialise the constant at the start
  #' of the simulation. The initialiser function takes the population size as
  #' its only argument

  initialize = function(name, initialiser) {
    private$.name <- name
    private$.initialiser <- initialiser
  },
  print_fields = c('name')
)
