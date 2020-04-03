#' Class: StateUpdate
#' Describes a state update
#' @export StateUpdate
StateUpdate <- R6::R6Class(
  'StateUpdate',
  public = list(

    #' @field individual, the individual to update
    individual = NULL,

    #' @field state, the state to move individuals to
    state = NULL,

    #' @field index, the index at which to update the states
    index = NULL,

    #' @field type, a helper field for the cpp implementation
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

    #' @field individual, the individual to update
    individual = NULL,

    #' @field variable, the variable to to update
    variable = NULL,

    #' @field value, the value to update the variable with
    value = NULL,

    #' @field index, the index of the variable to update
    index = NULL,

    #' @field type, a helper field for the cpp implementation
    type = 'variable',

    #' @description
    #' Create a new VariableUpdate descriptor. There are 4 types of variable
    #' Update:
    #'
    #' 1. Subset update. The index vector represents a subset of the variable to
    #' update. The value vector, of the same size, represents the new values for
    #' that subset
    #' 2. Subset fill. The index vector represents a subset of the variable to
    #' update. The value vector, of size 1, will fill the specified subset
    #' 3. Variable reset. The index vector is set to `NULL` and the value vector
    #' replaces all of the current values in the simulation. The value vector is
    #' should match the size of the population.
    #' 4. Variable fill. The index vector is set to `NULL` and the value vector,
    #' of size 1, is used to fill all of the variable values in the population.
    #' @param individual is the type of individual to update
    #' @param variable a Variable object representing the variable to change
    #' @param value a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use NULL for the
    #' fill options
    initialize = function(individual, variable, value, index=NULL) {
      if (is.null(individual)) {
        stop('individual cannot be null')
      }

      if (is.null(variable)) {
        stop('variable cannot be null')
      }
      self$individual <- individual
      self$value <- value
      self$variable <- variable
      self$index <- index
    }
  )
)
