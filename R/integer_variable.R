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
    #' @param initial_values a vector of the initial value for each which will be coerced to integer type
    #' individual
    initialize = function(initial_values) {
      self$.variable <- create_integer_variable(as.integer(initial_values))
    },

    #' @description get the variable values
    #' @param index optionally return a subset of the variable vector
    get_values = function(index=NULL) {
      if (is.null(index)) {
        return(integer_variable_get_values(self$.variable))
      }
      if (is.numeric(index)) {
        return(integer_variable_get_values_at_index_vector(self$.variable, index))
      }
      integer_variable_get_values_at_index(self$.variable, index$.bitset)
    },


    #' @description return a bitset for individuals with some subset of values
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range [a,b].
    #' @param set a vector of values 
    #' @param a lower bound
    #' @param b upper bound
    get_index_of = function(set = NULL, a = NULL, b = NULL) {        
        if(!is.null(set)) {
            return(Bitset$new(from = integer_variable_get_index_of_set(self$.variable, set)))
        }
        if(!is.null(a) & !is.null(b)) {
            stopifnot(a < b)
            return(Bitset$new(from = integer_variable_get_index_of_range(self$.variable, a, b)))            
        }
        stop("please provide a set of values to check, or both bounds of range [a,b]")        
    },

    #' @description return the number of individuals with some subset of values
    #' Either search for indices corresponding to values in \code{set}, or
    #' for indices corresponding to values in range [a,b].
    #' @param set a vector of values 
    #' @param a lower bound
    #' @param b upper bound
    get_size_of = function(set = NULL, a = NULL, b = NULL) {        
        if(!is.null(set)) {
            return(integer_variable_get_size_of_set(self$.variable, set))
        }
        if(!is.null(a) & !is.null(b)) {
            stopifnot(a < b)
            return(integer_variable_get_size_of_range(self$.variable, a, b))           
        }
        stop("please provide a set of values to check, or both bounds of range [a,b]")        
    },

    #' @description Queue an update for a variable. There are 4 types of variable update:
    #'
    #' 1. Subset update. The index vector represents a subset of the variable to
    #' update. The value vector, of the same size, represents the new values for
    #' that subset
    #' 2. Subset fill. The index vector represents a subset of the variable to
    #' update. The value vector, of size 1, will fill the specified subset
    #' 3. Variable reset. The index vector is set to `NULL` and the value vector
    #' replaces all of the current values in the simulation. The value vector
    #' should match the size of the population.
    #' 4. Variable fill. The index vector is set to `NULL` and the value vector,
    #' of size 1, is used to fill all of the variable values in the population.
    #' @param values a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use NULL for the
    #' fill options

    queue_update = function(values, index = NULL) {
      if(is.null(index)){
        if(length(values) == 1){
          integer_variable_queue_fill(
            self$.variable,
            values
          )
        } else {
          integer_variable_queue_update(
            self$.variable,
            values,
            numeric(0)
          )
        }
      } else {
        if (inherits(index, 'Bitset')) {
          index <- index$to_vector()
        }
        if (length(index) != 0) {
          integer_variable_queue_update(
            self$.variable,
            values,
            index
          )
        }
      }
    },

    .update = function() integer_variable_update(self$.variable)
  )
)
