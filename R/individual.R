#' Class: Individual
#' Represents an individual in our simulation
#' @export Individual
Individual <- R6::R6Class(
  'Individual',
  public = list(

    #' @field name the string label for this individual
    name = '',

    #' @field states a list of state objects which apply to this individual
    states = list(),

    #' @field variables a list of variable objects which apply to this individual
    variables = list(),

    #' @field events a list of event objects which apply to this individual
    events = list(),

    #' @field the number of these individuals in the simulation
    population_size = 0,

    #' @description Create a new Individual
    #' @param name is a unique idetifier which is used in the output
    #' @param states a list of State objects
    #' @param variables a list of Variable objects
    #' @param events a list of Event objects
    initialize = function(name, states, variables = list(), events = list()) {
      if (any(duplicated(vcapply(states, function (state) state$name)))) {
        stop('No duplicate state names allowed')
      }

      if (any(duplicated(vcapply(variables, function (v) v$name)))) {
        stop('No duplicate variable names allowed')
      }

      if (any(duplicated(vcapply(events, function (e) e$name)))) {
        stop('No duplicate event names allowed')
      }

      population_size <- sum(vnapply(states, function(s) s$initial_size))

      for (variable in variables) {
        if (length(variable$initial_values) != population_size) {
          stop(paste0(
            "the '",
            variable$name,
            "' variable's initial values must match the population size"
          ))
        }
      }

      self$name <- name
      self$states <- states
      self$population_size <- population_size
      self$variables <- variables
      self$events <- events
    }
  )
)

#' Class: State
#' Represents a state for an individual in our simulation
#' @export State
State <- R6::R6Class(
  'State',
  public = list(

    #' @field name the string label for this state
    name = '',

    #' @field initial_size the string label for this state
    initial_size = 0,

    #' @description Create a new State
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

    #' @field name the string label for this variable
    name = '',

    #' @field initial values for this variable
    initial_values = NULL,

    #' @description Create a new Variable. Variables represent a numerical value for each
    #' individual. Variables are updated during a simulation when a process
    #' returns a VariableUpdate object.
    #' @param name is a unique identifier which is used in the output
    #' @param initial_values the values for this variable at the start of the
    #' simulation
    initialize = function(name, initial_values) {
      self$name <- name
      self$initial_values <- initial_values
    }
  )
)
