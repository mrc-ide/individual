#' @title DoubleVariable Class
#' @description Represents a continuous variable for an individual.
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
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      if (is.null(index)) {
        return(double_variable_get_values(self$.variable))
      }
      if (is.numeric(index)) {
        return(double_variable_get_values_at_index_vector(self$.variable, index))
      }
      double_variable_get_values_at_index(self$.variable, index$.bitset)
    },

    #' @description return a \code{\link[individual]{Bitset}} giving individuals 
    #' whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(a, b) {
      stopifnot(a < b)
      return(Bitset$new(from = double_variable_get_index_of_range(self$.variable, a, b)))            
    },

    #' @description return the number of individuals whose value lies in an interval
    #' Count individuals whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(a, b) {
      stopifnot(a < b)
      double_variable_get_size_of_range(self$.variable, a, b)            
    },

    #' @description Queue an update for a variable. There are 4 types of variable update:
    #' \enumerate{
    #'  \item{Subset update: }{The argument \code{index} represents a subset of the variable to
    #' update. The argument \code{values} should be a vector whose length matches the size of \code{index},
    #' which represents the new values for that subset.}
    #'  \item{Subset fill: }{The argument \code{index} represents a subset of the variable to
    #' update. The argument \code{values} should be a single number, which fills the specified subset.}
    #'  \item{Variable reset: }{The index vector is set to \code{NULL} and the argument \code{values}
    #' replaces all of the current values in the simulation. \code{values} should be a vector
    #' whose length should match the size of the population, which fills all the variable values in
    #' the population}
    #'  \item{Variable fill: }{The index vector is set to \code{NULL} and the argument \code{values}
    #' should be a single number, which fills all of the variable values in 
    #' the population.}
    #' }
    #' @param values a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use \code{NULL} for the
    #' fill options. If using indices, this may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    queue_update = function(values, index = NULL) {
      stopifnot(is.numeric(values))
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
            integer(0)
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
