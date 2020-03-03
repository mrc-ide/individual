#' Class: Individual
#' Represents an individual in our simulation
#' @export Individual
Individual <- DataClass(
  'Individual',
  c('name', 'states', 'variables', 'constants'),

  #' @description
  #' Create a new Individual
  #' @param name is a unique idetifier which is used in the output
  #' $param ... a list of State objects
  #' $param variables a list of Variable objects
  #' $param constants a list of Constant objects

  initialize = function(name, states, variables = list(), constants = list()) {
    names <- c(
      vcapply(states, function(state) state$name),
      vcapply(variables, function(v) v$name),
      vcapply(constants, function(c) c$name)
    )

    if (any(duplicated(names))) {
      stop('No duplicate state, variable or constant names allowed')
    }

    private$.name <- name
    private$.states <- states
    private$.variables <- variables
    private$.constants <- constants
  },
  print_fields = c('name')
)

Individual$set(
  'public',
  'check_state',
  function(state) {
    names <- vcapply(self$states, function(s) s$name)
    state$name %in% names
  }
)

Individual$set(
  'public',
  'check_variable',
  function(variable) {
    names <- vcapply(self$variables, function(v) v$name)
    variable$name %in% names
  }
)

Individual$set(
  'public',
  'check_constant',
  function(constant) {
    names <- vcapply(self$constants, function(v) v$name)
    constant$name %in% names
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
  c('name', 'initialiser'),

  #' @description
  #' Create a new Variable. Variables represent a numerical value for each
  #' individual. Variables are updated during a simulation when a process
  #' returns a VariableUpdate object.
  #' @param name is a unique identifier which is used in the output
  #' @param initialiser a function used to initialise the variable at the start
  #' of the simulation. The initialiser function takes the population size as
  #' its only argument

  initialize = function(name, initialiser) {
    private$.name <- name
    private$.initialiser <- initialiser
  },
  print_fields = c('name')
)
