#' Class: Categorical Variable
#' Represents a categorical variable for an individual
#' Used to quickly find individuals who could be in one of many options
#' @export CategoricalVariable
CategoricalVariable <- R6::R6Class(
  'CategoricalVariable',
  public = list(

    #' @field initial_size the string label for this state
    .variable = NULL,

    #' @description Create a new CategoricalVariable
    #' @param initial_values a character vector of the initial value for each
    #' individual
    initialize = function(initial_values) {
      self$.variable <- create_categorical_variable(initial_values)
    },

    #' @description return a bitset for individuals with the given `values`
    #' @param values the values to filter
    get_index_of = function(values) {
      Bitset$new(from = categorical_variable_index_of(values))
    },

    #' @description queue an update for this variable
    #' @param values the values to filter
    queue_update = function(value, index) {
      categorical_variable_queue_update(value, index)
    },

    #' @noRd
    .update = function() categorical_variable_update()
  )
)

#' Class: DoubleVariable
#' Represents a double variable for an individual in our simulation
#' @export DoubleVariable
DoubleVariable <- R6::R6Class(
  'DoubleVariable',
  public = list(

    .variable = NULL,

    #' @description Create a new DoubleVariable
    #' @param initial_values a numeric vector of the initial value for each
    #' individual
    initialize = function(initial_values) {
      self$.variable <- create_double_variable(initial_values)
    },

    #' @description get the variable values
    #' @param index optionally return a subset of the variable vector
    get_values = function(index=NULL) {
      if (is.null(index)) {
        return(
          double_variable_get_values(self$.variable)
        )
      }
      double_variable_get_values_at_index(self$.variable, index)
    },

    #' @description Queue an update for a variable. There are 4 types of variable update:
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
    #' @param values a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use NULL for the
    #' fill options

    queue_update = function(values, index) {
      if(is.null(index)){
        if(length(values) == 1){
          double_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          double_variable_queue_update(
            self$.variable,
            numeric(0),
            values
          )
        }
      } else if(length(index) != 0) {
        double_variable_queue_update(
          self$.variable,
          index,
          values
        )
      }
    },

    #' @noRd
    .update = function() double_variable_update()
  )
)
