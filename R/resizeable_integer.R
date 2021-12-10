#' @title ResizeableIntegerVariable Class
#' @description Represents an integer variable for a varying popuation size.
#' Value updates are applied as in IntegerVariable. Resizing updates (i.e.
#' extend and shrink updates) are applied after all value updates are applied.
#' @importFrom R6 R6Class
#' @export
ResizeableIntegerVariable <- R6Class(
  'ResizeableIntegerVariable',
  inherit = IntegerVariable,
  private = list(
    resize_interface = NULL
  ),
  public = list(
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.finite(initial_values))
      self$.variable <- create_resizeable_integer_variable(as.integer(initial_values))
      private$variable_interface <- VariableInterface$new(
        variable = self$.variable,
        interface = list(
          get_size = resizeable_integer_variable_size,
          get_values = resizeable_integer_variable_get_values,
          get_values_at_index = resizeable_integer_variable_get_values_at_index,
          get_values_at_index_vector = resizeable_integer_variable_get_values_at_index_vector,
          queue_fill = resizeable_integer_variable_queue_fill,
          queue_update = resizeable_integer_variable_queue_update,
          queue_update_bitset = resizeable_integer_variable_queue_update_bitset,
          queue_update = resizeable_integer_variable_queue_update,
          update = resizeable_integer_variable_update
        )
      )
      private$integer_interface <- IntegerInterface$new(
        variable = self$.variable,
        interface = list(
          get_index_of_set_scalar = resizeable_integer_variable_get_index_of_set_scalar,
          get_index_of_set_vector = resizeable_integer_variable_get_index_of_set_vector,
          get_index_of_range = resizeable_integer_variable_get_index_of_range,
          get_size_of_set_scalar = resizeable_integer_variable_get_size_of_set_scalar,
          get_size_of_set_vector = resizeable_integer_variable_get_size_of_set_vector,
          get_size_of_range = resizeable_integer_variable_get_size_of_range,
          get_size_of_set_scalar = resizeable_integer_variable_get_size_of_set_scalar
        )
      )
      private$resize_interface <- ResizeInterface$new(
        variable = self$.variable,
        interface = list(
          queue_extend = resizeable_integer_variable_queue_extend,
          queue_shrink_bitset = resizeable_integer_variable_queue_shrink_bitset,
          queue_shrink = resizeable_integer_variable_queue_shrink
        )
      )
    },

    #' @description extend the variable with new values
    #' @param values to add to the variable
    queue_extend = function(values) {
      private$resize_interface$queue_extend(values)
    },

    #' @description shrink the variable
    #' @param index a bitset or vector representing the individuals to remove
    queue_shrink = function(index) {
      private$resize_interface$queue_shrink(index)
    },

    #' @description get the current size of the variable
    size = function() resizeable_integer_variable_size(self$.variable)
  )
)
