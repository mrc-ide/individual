#' Class: Individual
#' Represents an individual in our simulation
#' @export Individual
Individual <- R6::R6Class(
  'Individual',
  public = list(
    name = '',
    states = list(),
    variables = list(),

    #' @description
    #' Create a new Individual
    #' @param name is a unique idetifier which is used in the output
    #' $param ... a list of State objects
    #' $param variables a list of Variable objects
    #' $param constants a list of Constant objects
    initialize = function(name, states, variables = list()) {
      if (any(duplicated(vcapply(states, function (state) state$name)))) {
        stop('No duplicate state names allowed')
      }

      if (any(duplicated(vcapply(variables, function (v) v$name)))) {
        stop('No duplicate variable names allowed')
      }

      self$name <- name
      self$states <- states
      self$variables <- variables
    }
  )
)

#' Class: State
#' Represents a state for an individual in our simulation
#' @export State
State <- R6::R6Class(
  'State',
  public = list(
    name = '',
    initial_size = 0,

    #' @description
    #' Create a new State
    #' @param name is a unique idetifier which is used in the output
    #' @param initial_size used to initialise the state at the start of the sim
    initialize = function(name, initial_size) {
      if (initial_size < 0) {
        stop('Invalid size')
      }
      self$name <- name
      self$initial_size <- initial_size
    }
  )
)

#' Class: Variable
#' Represents a variable for an individual in our simulation
#' @export Variable
Variable <- R6::R6Class(
  'Variable',
  public = list(
    name = '',
    initialiser = NULL,

    #' @description
    #' Create a new Variable. Variables represent a numerical value for each
    #' individual. Variables are updated during a simulation when a process
    #' returns a VariableUpdate object.
    #' @param name is a unique identifier which is used in the output
    #' @param initialiser a function used to initialise the variable at the start
    #' of the simulation. The initialiser function takes the population size as
    #' its only argument
    initialize = function(name, initialiser) {
      self$name <- name
      self$initialiser <- initialiser
    }
  )
)
