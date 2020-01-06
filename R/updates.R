#' Class: StateUpdate
#' Describes a state update
#' @export StateUpdate
StateUpdate <- DataClass(
  'StateUpdate',
  c('individual', 'index', 'state'),

  #' @description
  #' Create a new StateUpdate descriptor
  #' @param individual is the type of individual to update
  #' @param index is the index at which to apply the change
  #' @param state is the destination state of the update

  initialize = function(individual, index, state) {
    private$.individual <- individual
    private$.index <- index
    private$.state <- state
  }
)

#' Class: VariableUpdate
#' Describes an update to a variable
#' @export VariableUpdate
VariableUpdate <- DataClass(
  'VariableUpdate',
  c('individual', 'index', 'value', 'variable'),

  #' @description
  #' Create a new VariableUpdate descriptor
  #' @param individual is the type of individual to update
  #' @param index is the index at which to apply the change
  #' @param value a vector or scalar of values to assign at the index
  #' @param variable a Variable object representing the variable to change

  initialize = function(individual, index, value, variable) {
    private$.individual <- individual
    private$.index <- index
    private$.value <- value
    private$.variable <- variable
  }
)
