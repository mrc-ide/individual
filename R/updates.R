#' Class: StateUpdate
#' Describes a state update
#' @export StateUpdate
StateUpdate <- R6::R6Class(
  'StateUpdate',
  public = list(
    individual = NULL,
    state = NULL,
    index = NULL,
    type = 'state',

    #' @description
    #' Create a new StateUpdate descriptor
    #' @param individual is the type of individual to update
    #' @param state is the destination state of the update
    #' @param index is the index at which to apply the change
    initialize = function(individual, state, index) {
      self$individual <- individual
      self$index <- index
      self$state <- state
    }
  )
)

#' Class: VariableUpdate
#' Describes an update to a variable
#' @export VariableUpdate
VariableUpdate <- R6::R6Class(
  'VariableUpdate',
  public = list(
    individual = NULL,
    variable = NULL,
    value = NULL,
    index = NULL,
    type = 'variable',

    #' @description
    #' Create a new VariableUpdate descriptor
    #' @param individual is the type of individual to update
    #' @param variable a Variable object representing the variable to change
    #' @param value a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change
    initialize = function(individual, variable, value, index=NULL) {
      self$individual <- individual
      self$value <- value
      self$variable <- variable
      self$index <- index
    }
  )
)
