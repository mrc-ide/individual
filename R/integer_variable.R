#' @title IntegerVariable Class
#' @description Represents a integer valued variable for an individual.
#' This class is similar to \code{\link[individual]{CategoricalVariable}},
#' but can be used for variables with unbounded ranges, or other situations where part
#' of an individual's state is better represented by an integer, such as
#' household or age bin.
#' @importFrom R6 R6Class
#' @export
IntegerVariable <- R6Class(
  'IntegerVariable',
  private = list(
    variable_interface = NULL,
    integer_interface = NULL
  ),
  public = list(
    .variable = NULL,

    #' @description Create a new IntegerVariable.
    #' @param initial_values a vector of the initial values for each individual
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.finite(initial_values))
      self$.variable <- create_integer_variable(as.integer(initial_values))
      private$variable_interface <- VariableInterface$new(
        variable = self$.variable,
        interface = list(
          get_size = integer_variable_get_size,
          get_values = integer_variable_get_values,
          get_values_at_index = integer_variable_get_values_at_index,
          get_values_at_index_vector = integer_variable_get_values_at_index_vector,
          queue_fill = integer_variable_queue_fill,
          queue_update = integer_variable_queue_update,
          queue_update_bitset = integer_variable_queue_update_bitset,
          queue_update = integer_variable_queue_update,
          update = integer_variable_update
        )
      )
      private$integer_interface <- IntegerInterface$new(
        variable = self$.variable,
        interface = list(
          get_index_of_set_scalar = integer_variable_get_index_of_set_scalar,
          get_index_of_set_vector = integer_variable_get_index_of_set_vector,
          get_index_of_range = integer_variable_get_index_of_range,
          get_size_of_set_scalar = integer_variable_get_size_of_set_scalar,
          get_size_of_set_vector = integer_variable_get_size_of_set_vector,
          get_size_of_range = integer_variable_get_size_of_range,
          get_size_of_set_scalar = integer_variable_get_size_of_set_scalar
        )
      )
    },

    #' @description Get the variable values.
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      private$variable_interface$get_values(index)
    },

    #' @description Return a \code{\link[individual]{Bitset}} for individuals with some subset of values.
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values (providing \code{set} means \code{a,b} are ignored)
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(set = NULL, a = NULL, b = NULL) {
      private$integer_interface$get_index_of(set, a, b)
    },

    #' @description Return the number of individuals with some subset of values.
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values (providing \code{set} means \code{a,b} are ignored)
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(set = NULL, a = NULL, b = NULL) {    
      private$integer_interface$get_size_of(set, a, b)
    },
    
    #' @description Queue an update for a variable. There are 4 types of variable update:
    #'
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
      private$variable_interface$queue_update(values, index)
    },

    .update = function() private$variable_interface$update()
  )
)

#' @title IntegerInterface Class
#' @description An interface for integer set operations
#' @importFrom R6 R6Class
IntegerInterface <- R6Class(
  'IntegerInterface',
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

    #' @description Return a \code{\link[individual]{Bitset}} for individuals with some subset of values.
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values (providing \code{set} means \code{a,b} are ignored)
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(set = NULL, a = NULL, b = NULL) {
        if (!is.null(set)) {
          stopifnot(is.finite(set))
          if (length(set) == 1) {
            return(Bitset$new(from = private$interface$get_index_of_set_scalar(private$variable, set)))
          } else {
            return(Bitset$new(from = private$interface$get_index_of_set_vector(private$variable, set)))
          }
        } else {
          stopifnot(is.finite(c(a,b)))
          stopifnot(a <= b)
          if (a < b) {
            return(Bitset$new(from = private$interface$get_index_of_range(private$variable, a, b)))              
          } else {
            return(Bitset$new(from = private$interface$get_index_of_set_scalar(private$variable, a))) 
          }
        }
        stop("please provide a set of values to check, or both bounds of range [a,b]")        
    },

    #' @description Return the number of individuals with some subset of values.
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range \eqn{[a,b]}. Either \code{set}
    #' or \code{a} and \code{b} must be provided as arguments.
    #' @param set a vector of values (providing \code{set} means \code{a,b} are ignored)
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(set = NULL, a = NULL, b = NULL) {    
      if (!is.null(set)) {
        stopifnot(is.finite(set))  
        if (length(set) == 1) {
          return(private$interface$get_size_of_set_scalar(private$variable, set))
        } else {
          return(private$interface$get_size_of_set_vector(private$variable, set))
        }
      } else {
        stopifnot(is.finite(c(a,b)))
        stopifnot(a <= b)
        if (a < b) {
          return(private$interface$get_size_of_range(private$variable, a, b))
        } else {
          return(private$interface$get_size_of_set_scalar(private$variable, a))
        }
      }
      stop("please provide a set of values to check, or both bounds of range [a,b]")    
    }
  )
)
