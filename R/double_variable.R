#' @title DoubleVariable Class
#' @description Represents a continuous variable for an individual.
#' @importFrom R6 R6Class
#' @export
DoubleVariable <- R6Class(
  'DoubleVariable',
  public = list(
    .variable = NULL,

    #' @description Create a new DoubleVariable.
    #' @param initial_values a numeric vector of the initial value for each
    #' individual.
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.numeric(initial_values))
      self$.variable <- create_double_variable(initial_values)
    },

    #' @description get the variable values.
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      if (is.null(index)) {
        return(double_variable_get_values(self$.variable))
      } else {
        if (inherits(index, 'Bitset')) {
          return(double_variable_get_values_at_index(self$.variable, index$.bitset))
        } else {
          stopifnot(is.finite(index))
          stopifnot(index > 0)
          return(double_variable_get_values_at_index_vector(self$.variable, index))
        }
      }
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
      return(double_variable_get_size_of_range(self$.variable, a, b))
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
    #' @param values a vector or scalar of values to assign at the index.
    #' @param index is the index at which to apply the change, use \code{NULL} for the
    #' fill options. If using indices, this may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    queue_update = function(values, index = NULL) {
      stopifnot(is.numeric(values), !is.null(values))
      if(is.null(index)){
        if(length(values) == 1){
          # variable fill
          double_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          # variable reset
          stopifnot(length(values) == variable_get_size(self$.variable))
          double_variable_queue_update(
            self$.variable,
            values,
            integer(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          # subset update/fill: bitset
          stopifnot(index$max_size == variable_get_size(self$.variable))
          if (index$size() > 0){
            double_variable_queue_update_bitset(
              self$.variable,
              values,
              index$.bitset
            )
          }
        } else {
          if (length(index) != 0) {
            # subset update/fill: vector
            stopifnot(is.finite(index))
            stopifnot(index > 0)
            double_variable_queue_update(
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
      double_variable_queue_extend(self$.variable, values)
    },

    #' @description shrink the variable
    #' @param index a bitset or vector representing the individuals to remove
    queue_shrink = function(index) {
      if (inherits(index, 'Bitset')) {
        if (index$size() > 0){
          double_variable_queue_shrink_bitset(
            self$.variable,
            index$.bitset
          )
        }
      } else {
        if (length(index) != 0) {
          stopifnot(all(is.finite(index)))
          stopifnot(all(index > 0))
          double_variable_queue_shrink(self$.variable, index)
        }
      }
    },

    #' @description get the size of the variable
    size = function() variable_get_size(self$.variable),

    .update = function() variable_update(self$.variable),
    .resize = function() variable_resize(self$.variable),

    #' @description save the state of the variable
    save_state = function() self$get_values(),

    #' @description restore the variable from a previously saved state.
    #' @param timestep the timestep at which simulation is resumed. This
    #' parameter's value is ignored, it only exists to conform to a uniform
    #' interface with events.
    #' @param state the previously saved state, as returned by the
    #' \code{save_state} method. NULL is passed when restoring from a saved
    #' simulation in which this variable did not exist.
    restore_state = function(timestep, state) {
      if (!is.null(state)) {
        stopifnot(length(state) == variable_get_size(self$.variable))
        self$queue_update(state)
        self$.update()
      }
    }
  )
)
