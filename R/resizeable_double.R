#' @title ResizeableDoubleVariable Class
#' @description Represents a continuous variable for a varying popuation size.
#' Value updates are applied as in DoubleVariable. Resizing updates (i.e.
#' extend and shrink updates) are applied after all value updates are applied.
#' @importFrom R6 R6Class
#' @export
ResizeableDoubleVariable <- R6Class(
  'ResizeableDoubleVariable',
  inherit = DoubleVariable,
  private = list(
    resize_interface = NULL
  ),
  public = list(
    initialize = function(initial_values) {
      stopifnot(!is.null(initial_values))
      stopifnot(is.finite(initial_values))
      self$.variable <- create_resizeable_double_variable(initial_values)
      private$variable_interface <- VariableInterface$new(
        variable = self$.variable,
        interface = list(
          get_size = resizeable_double_variable_size,
          get_values = resizeable_double_variable_get_values,
          get_values_at_index = resizeable_double_variable_get_values_at_index,
          get_values_at_index_vector = resizeable_double_variable_get_values_at_index_vector,
          queue_fill = resizeable_double_variable_queue_fill,
          queue_update = resizeable_double_variable_queue_update,
          queue_update_bitset = resizeable_double_variable_queue_update_bitset,
          update = resizeable_double_variable_update
        )
      )
      private$double_interface <- DoubleInterface$new(
        variable = self$.variable,
        interface = list(
          get_index_of_range = resizeable_double_variable_get_index_of_range,
          get_size_of_range = resizeable_double_variable_get_size_of_range
        )
      )
      private$resize_interface <- ResizeInterface$new(
        variable = self$.variable,
        interface = list(
          queue_extend = resizeable_double_variable_queue_extend,
          queue_shrink_bitset = resizeable_double_variable_queue_shrink_bitset,
          queue_shrink = resizeable_double_variable_queue_shrink
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
    size = function() resizeable_double_variable_size(self$.variable)
  )
)
