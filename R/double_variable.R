#' @title DoubleVariable Class
#' @description Represents a continuous variable for an individual.
#' @importFrom R6 R6Class
#' @export
DoubleVariable <- R6Class(
  'DoubleVariable',
  private = list(
    variable_interface = NULL,
    double_interface = NULL
  ),
  public = list(
    .variable = NULL,

    #' @description Create a new DoubleVariable.
    #' @param initial_values a numeric vector of the initial value for each
    #' individual.
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.numeric(initial_values))
      self$.variable <- create_double_variable(initial_values)
      private$variable_interface <- VariableInterface$new(
        variable = self$.variable,
        interface = list(
          get_size = double_variable_get_size,
          get_values = double_variable_get_values,
          get_values_at_index = double_variable_get_values_at_index,
          get_values_at_index_vector = double_variable_get_values_at_index_vector,
          queue_fill = double_variable_queue_fill,
          queue_update = double_variable_queue_update,
          queue_update_bitset = double_variable_queue_update_bitset,
          update = double_variable_update
        )
      )
      private$double_interface <- DoubleInterface$new(
        variable = self$.variable,
        interface = list(
          get_index_of_range = double_variable_get_index_of_range,
          get_size_of_range = double_variable_get_size_of_range
        )
      )
    },

    #' @description get the variable values.
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      private$variable_interface$get_values(index)
    },

    #' @description return a \code{\link[individual]{Bitset}} giving individuals 
    #' whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(a, b) private$double_interface$get_index_of(a, b),

    #' @description return the number of individuals whose value lies in an interval
    #' Count individuals whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(a, b) private$double_interface$get_size_of(a, b),

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
    #' @param values a vector or scalar of values to assign at the index.
    #' @param index is the index at which to apply the change, use \code{NULL} for the
    #' fill options. If using indices, this may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    queue_update = function(values, index = NULL) {
      private$variable_interface$queue_update(values, index)
    },

    .update = function() private$variable_interface$update()
  )
)

#' @title DoubleInterface Class
#' @description An interface for double indexing operations
#' @importFrom R6 R6Class
DoubleInterface <- R6Class(
  'DoubleInterface',
  private = list(
    variable = NULL,
    interface = NULL
  ),
  public = list(
    #' @description initialise this interface
    #' @param variable a C++ object implementing this variable
    #' @param interface a list of C++ functions implementing this interface
    initialize = function(variable, interface) {
      private$variable <- variable
      private$interface <- interface
    },

    #' @description return a \code{\link[individual]{Bitset}} giving individuals 
    #' whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(a, b) {
      stopifnot(a < b)
      return(Bitset$new(from = private$interface$get_index_of_range(private$variable, a, b)))      
    },

    #' @description return the number of individuals whose value lies in an interval
    #' Count individuals whose value lies in an interval \eqn{[a,b]}.
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(a, b) {
      stopifnot(a < b)
      return(private$interface$get_size_of_range(private$variable, a, b))
    }
  )
)
