#' @title Categorical Variable Class
#' @description Represents a categorical variable for an individual.
#' This class should be used for discrete variables taking values in 
#' a finite set, such as infection, health, or behavioral state. It should
#' be used in preference to \code{\link[individual]{IntegerVariable}}
#' if possible becuase certain operations will be faster.
#' @importFrom R6 R6Class
#' @export
CategoricalVariable <- R6Class(
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

    #' @description return a \code{\link[individual]{Bitset}} for individuals with the given \code{values}
    #' @param values the values to filter
    get_index_of = function(values) {
      Bitset$new(from = categorical_variable_get_index_of(self$.variable, values))
    },

    #' @description return the number of individuals with the given \code{values}
    #' @param values the values to filter
    get_size_of = function(values) {
      categorical_variable_get_size_of(self$.variable, values)
    },

    #' @description return a character vector of possible values.
    #' Note that the order of the returned vector may not be the same order
    #' that was given when the variable was intitialized, due to the underlying
    #' unordered storage type. 
    get_categories = function() {
      categorical_variable_get_categories(self$.variable)
    },

    #' @description queue an update for this variable
    #' @param values the new values
    #' @param index the indices of individuals whose value will be updated
    #' to the one specified in \code{values}. This may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    queue_update = function(value, index) {
      stopifnot(all(value %in% self$get_categories()))
      if (inherits(index, "Bitset")) {
        categorical_variable_queue_update(self$.variable, value, index$.bitset)        
      } else {
        categorical_variable_queue_update_vector(self$.variable, value, as.integer(index))
      }
    },

    .update = function() categorical_variable_update(self$.variable)
  )
)
