#' @title VariableInterface Class
#' @description Common functionality for all variables
#' @importFrom R6 R6Class
VariableInterface <- R6Class(
  'VariableInterface',
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

    #' @description Get the variable values.
    #' @param index optionally return a subset of the variable vector. If
    #' \code{NULL}, return all values; if passed a \code{\link[individual]{Bitset}}
    #' or integer vector, return values of those individuals.
    get_values = function(index = NULL) {
      if (is.null(index)) {
        return(private$interface$get_values(private$variable))
      } else{
        if (inherits(index, 'Bitset')){
          return(private$interface$get_values_at_index(private$variable, index$.bitset))
        } else {
          stopifnot(index > 0)
          stopifnot(is.finite(index))
          return(private$interface$get_values_at_index_vector(private$variable, index))
        }
      }
      
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
      stopifnot(is.finite(values))
      if(is.null(index)){
        if(length(values) == 1){
          # variable fill
          private$interface$queue_fill(
            private$variable,
            values
          )
        } else {
          # variable reset
          stopifnot(length(values) == private$interface$get_size(private$variable))
          private$interface$queue_update(
            private$variable,
            values,
            integer(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          # subset update/fill: bitset
          stopifnot(index$max_size == private$interface$get_size(private$variable))
          if (index$size() > 0) {
            private$interface$queue_update_bitset(
              private$variable,
              values,
              index$.bitset
            )
          }
        } else {
          if (length(index) > 0) {
            # subset update/fill: vector
            stopifnot(is.finite(index))
            stopifnot(index > 0)
            private$interface$queue_update(
              private$variable,
              values,
              index
            )
          }
        }

      }
    },

    update = function() private$interface$update(private$variable)
  )
)
