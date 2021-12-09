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
    implementation = list(
      create = create_resizeable_double_variable,
      get_values = resizeable_double_variable_get_values,
      get_size = resizeable_double_variable_size,
      get_values_at_index = resizeable_double_variable_get_values_at_index,
      get_values_at_index_vector = resizeable_double_variable_get_values_at_index_vector,
      get_index_of_range = resizeable_double_variable_get_index_of_range,
      get_size_of_range = resizeable_double_variable_get_size_of_range,
      queue_fill = resizeable_double_variable_queue_fill,
      queue_update = resizeable_double_variable_queue_update,
      queue_update_bitset = resizeable_double_variable_queue_update_bitset,
      update = resizeable_double_variable_update
    )
  ),
  public = list(
    #' @description extend the variable with new values
    #' @param values to add to the variable
    queue_extend = function(values) {
      stopifnot(is.numeric(values))
      resizeable_double_variable_queue_extend(
        self$.variable,
        values
      )
    },

    #' @description shrink the variable
    #' @param index a bitset or vector representing the individuals to remove
    queue_shrink = function(index) {
      if (inherits(index, 'Bitset')) {
        if (index$size() > 0){
          resizeable_double_variable_queue_shrink_bitset(
            self$.variable,
            index$.bitset
          )
        }
      } else {
        if (length(index) != 0) {
          stopifnot(is.finite(index))
          stopifnot(index > 0)
          resizeable_double_variable_queue_shrink(
            self$.variable,
            index
          )
        }
      }
    },

    #' @description get the current size of the variable
    size = function() resizeable_double_variable_size(self$.variable)
  )
)
