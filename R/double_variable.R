#' @title DoubleVariable Class
#' @description Represents a continuous variable for an individual in our simulation
#' @export
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
        return(double_variable_get_values(self$.variable))
      }
      if (is.numeric(index)) {
        return(double_variable_get_values_at_index_vector(self$.variable, index))
      }
      double_variable_get_values_at_index(self$.variable, index$.bitset)
    },

    #' @description return a bitset for individuals whose value lies in an interval
    #' Search for indices corresponding to values in the interval [a,b].
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(a, b) {
      stopifnot(a < b)
      return(Bitset$new(from = double_variable_get_index_of_range(self$.variable, a, b)))            
    },

    #' @description return the number of individuals whose value lies in an interval
    #' Count individuals whose value lies in the interval [a,b].
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(a, b) {
      stopifnot(a < b)
      double_variable_get_size_of_range(self$.variable, a, b)            
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

    queue_update = function(values, index = NULL) {
      if(is.null(index)){
        if(length(values) == 1){
          double_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          double_variable_queue_update(
            self$.variable,
            values,
            numeric(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          index <- index$to_vector()
        }
        if (length(index) != 0) {
          double_variable_queue_update(
            self$.variable,
            values,
            index
          )
        }
      }
    },

    .update = function() double_variable_update(self$.variable)
  )
)
