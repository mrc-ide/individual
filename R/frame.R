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
      state_names <- vcapply(states, function(state) state$name)
      private$.impl$get_state(individual$name, state_names)
    },

    #' @description
    #' Get a variable vector for an individual
    #' @param individual of interest
    #' @param variable of interest
    get_variable = function(individual, variable) {
      private$.impl$get_variable(individual$name, variable$name)
    },

    #' @description
    #' Get a constant vector for an individual
    #' @param individual of interest
    #' @param constant of interest
    get_constant = function(individual, constant) {
      private$.impl$get_variable(individual$name, constant$name)
    },

    #' @description
    #' Create an initial SimFrame
    #' @param individuals is a list of Individual
    #' @param state is a list of states for each individual at the current
    #' timestep
    #' @param variables is a list of variables for each individual at the
    #' current timestep
    #' @param constants is a list of constants for each individual at the
    #' current timestep
    initialize = function(individuals, states, variables, constants) {
      names <- lapply(individuals, function(i) { i$name })
      private$.impl <- new(
        SimFrameCpp,
        individuals,
        setNames(states, names),
        setNames(variables, names),
        setNames(constants, names)
      )
    }
  )
)
