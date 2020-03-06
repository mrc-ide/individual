#' Class: StateUpdate
#' Describes a state update
#' @export StateUpdate
StateUpdate <- DataClass(
  'StateUpdate',
  c('individual', 'state', 'index', 'type'),

  #' @description
  #' Create a new StateUpdate descriptor
  #' @param individual is the type of individual to update
  #' @param state is the destination state of the update
  #' @param index is the index at which to apply the change

  initialize = function(individual, state, index) {
    private$.type <- 'state'
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
  c('individual', 'variable', 'value', 'index', 'type'),

  #' @description
  #' Create a new VariableUpdate descriptor
  #' @param individual is the type of individual to update
  #' @param variable a Variable object representing the variable to change
  #' @param value a vector or scalar of values to assign at the index
  #' @param index is the index at which to apply the change

  initialize = function(individual, variable, value, index=NULL) {
    private$.type <- 'variable'
    private$.individual <- individual
    private$.value <- value
    private$.variable <- variable
    private$.index <- index
  }
)
