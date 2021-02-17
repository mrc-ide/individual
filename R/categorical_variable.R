#' @title Categorical Variable Class
#' @description Represents a categorical variable for an individual
#' Used to quickly find individuals who could be in one of many options
#' @export
CategoricalVariable <- R6::R6Class(
  'CategoricalVariable',
  public = list(

    .variable = NULL,

    #' @description Create a new CategoricalVariable
    #' @param categories a character vector of possible values
    #' @param initial_values a character vector of the initial value for each
    #' individual
    initialize = function(categories, initial_values) {
      self$.variable <- create_categorical_variable(categories, initial_values)
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