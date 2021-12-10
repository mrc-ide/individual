#' @title ResizeInterface Class
#' @description Functionality for resizing variables
#' @importFrom R6 R6Class
ResizeInterface <- R6Class(
  'ResizeInterface',
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

    #' @description extend the variable with new values
    #' @param values to add to the variable
    queue_extend = function(values) {
      stopifnot(is.numeric(values))
      private$interface$queue_extend(private$variable, values)
    },

    #' @description shrink the variable
    #' @param index a bitset or vector representing the individuals to remove
    queue_shrink = function(index) {
      if (inherits(index, 'Bitset')) {
        if (index$size() > 0){
          private$interface$queue_shrink_bitset(
            private$variable,
            index$.bitset
          )
        }
      } else {
        if (length(index) != 0) {
          stopifnot(all(is.finite(index)))
          stopifnot(all(index > 0))
          private$interface$queue_shrink(private$variable, index)
        }
      }
    }
  )
)
