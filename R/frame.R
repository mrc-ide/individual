#' Class: SimFrame
#' Represents the state of all individuals in a timestep
SimFrame <- R6::R6Class(
  'SimFrame',
  private = list(
    .impl = NULL
  ),
  public = list(
    #' @description
    #' Get the index of individuals with a particular state
    #' @param individual of interest
    #' @param state of interest
    get_state = function(individual, ...) {
      states <- list(...)
      for (state in states) {
        if(!individual$check_state(state)) {
          stop('Invalid state')
        }
      }
      private$.impl$get_state(individual, states)
    },

    #' @description
    #' Get a variable vector for an individual
    #' @param individual of interest
    #' @param variable of interest
    get_variable = function(...) {
      private$.impl$get_variable(...)
    },

    #' @description
    #' Get a constant vector for an individual
    #' @param individual of interest
    #' @param constant of interest
    get_constant = function(...) {
      private$.impl$get_variable(...)
    },

    #' @description
    #' Create an initial SimFrame
    #' current timestep
    #' @param the cpp implementation of this class
    initialize = function(impl) {
      private$.impl <- impl
    }
  )
)
