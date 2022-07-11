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
  public = list(

    .variable = NULL,

    #' @description Create a new IntegerVariable.
    #' @param initial_values a vector of the initial values for each individual
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.finite(initial_values))
      self$.variable <- create_integer_variable(as.integer(initial_values))
    },

    #' @description Get the variable values.
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      if (is.null(index)) {
        return(integer_variable_get_values(self$.variable))
      } else{
        if (inherits(index, 'Bitset')){
          return(integer_variable_get_values_at_index(self$.variable, index$.bitset))
        } else {
          stopifnot(index > 0)
          stopifnot(is.finite(index))
          return(integer_variable_get_values_at_index_vector(self$.variable, index))
        }
      }

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
            return(Bitset$new(from = integer_variable_get_index_of_set_scalar(self$.variable, set)))
          } else {
            return(Bitset$new(from = integer_variable_get_index_of_set_vector(self$.variable, set)))
          }
        } else {
          stopifnot(is.finite(c(a,b)))
          stopifnot(a <= b)
          if (a < b) {
            return(Bitset$new(from = integer_variable_get_index_of_range(self$.variable, a, b)))
          } else {
            return(Bitset$new(from = integer_variable_get_index_of_set_scalar(self$.variable, a)))
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
          return(integer_variable_get_size_of_set_scalar(self$.variable, set))
        } else {
          return(integer_variable_get_size_of_set_vector(self$.variable, set))
        }
      } else {
        stopifnot(is.finite(c(a,b)))
        stopifnot(a <= b)
        if (a < b) {
          return(integer_variable_get_size_of_range(self$.variable, a, b))
        } else {
          return(integer_variable_get_size_of_set_scalar(self$.variable, a))
        }
      }
      stop("please provide a set of values to check, or both bounds of range [a,b]")
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
      stopifnot(is.finite(values), !is.null(values))
      if(is.null(index)){
        if(length(values) == 1){
          # variable fill
          integer_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          # variable reset
          stopifnot(length(values) == variable_get_size(self$.variable))
          integer_variable_queue_update(
            self$.variable,
            values,
            integer(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          # subset update/fill: bitset
          stopifnot(index$max_size == variable_get_size(self$.variable))
          if (index$size() > 0) {
            integer_variable_queue_update_bitset(
              self$.variable,
              values,
              index$.bitset
            )
          }
        } else {
          if (length(index) > 0) {
            # subset update/fill: vector
            stopifnot(is.finite(index))
            stopifnot(index > 0)
            integer_variable_queue_update(
              self$.variable,
              values,
              index
            )
          }
        }

      }
    },

    #' @description extend the variable with new values
    #' @param values to add to the variable
    queue_extend = function(values) {
      stopifnot(is.numeric(values))
      integer_variable_queue_extend(self$.variable, values)
    },

    #' @description shrink the variable
    #' @param index a bitset or vector representing the individuals to remove
    queue_shrink = function(index) {
      if (inherits(index, 'Bitset')) {
        if (index$size() > 0){
          integer_variable_queue_shrink_bitset(
            self$.variable,
            index$.bitset
          )
        }
      } else {
        if (length(index) != 0) {
          stopifnot(all(is.finite(index)))
          stopifnot(all(index > 0))
          integer_variable_queue_shrink(self$.variable, index)
        }
      }
    },

    #' @description get the size of the variable
    size = function() variable_get_size(self$.variable),

    .update = function() variable_update(self$.variable),
    .resize = function() variable_resize(self$.variable)
  )
)
