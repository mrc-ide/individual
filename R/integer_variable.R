#' @title Integer Variable Class
#' @description Represents a integer-valued variable for an individual.
#' This class is similar to \code{\link[individual]{CategoricalVariable}},
#' but can be used for variables with unbounded ranges, or other situations where part
#' of an individual's state is better represented by an integer, such as
#' household or age bin.
#' @export
IntegerVariable <- R6::R6Class(
  'IntegerVariable',
  public = list(

    .variable = NULL,

    #' @description Create a new IntegerVariable
    #' @param categories a character vector of possible values
    #' @param initial_values a character vector of the initial value for each
    #' individual
    initialize = function(initial_values) {
      self$.variable <- create_integer_variable(categories, initial_values)
    },

    #' @description return a bitset for individuals with the given `values`
    #' @param values the values to filter
    get_index_of = function(values) {
      Bitset$new(from = categorical_variable_get_index_of(self$.variable, values))
    },

    #' @description queue an update for this variable
    #' @param values the values to filter
    queue_update = function(value, index) {
      if (is.numeric(index)) {
        categorical_variable_queue_update_vector(self$.variable, value, index)
      } else {
        categorical_variable_queue_update(self$.variable, value, index$.bitset)
      }
    },

    .update = function() categorical_variable_update(self$.variable)
  )
)
