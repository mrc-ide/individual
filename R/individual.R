#individual_cpp <- Module('individual_cpp', getDynLib(fx))

#' Class: Individual
#' Represents an individual in our simulation
#' @export Individual
#Individual <- individual_cpp$Individual
Individual <- list()

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

#' Class: Constant
#' Represents a constant for an individual in our simulation
#' @export Constant
Constant <- DataClass(
  'Constant',
  c('name', 'initialiser'),

  #' @description
  #' Create a new Constant. Constant represent a numerical value for each
  #' individual. Constants differ from variables in that they cannot be updated
  #' in the simulation.
  #' @param name is a unique identifier which is used in the output
  #' @param initialiser a function used to initialise the constant at the start
  #' of the simulation. The initialiser function takes the population size as
  #' its only argument

  initialize = function(name, initialiser) {
    private$.name <- name
    private$.initialiser <- initialiser
  },
  print_fields = c('name')
)
