#' Class: SimAPI
#' The entry point for models to inspect and manipulate the simulation
SimAPI <- R6::R6Class(
  'SimAPI',
  private = list(
    .simulation = NULL
    .scheduler = NULL
  ),
  public = list(
    #' @description
    #' Get the index of individuals with a particular state
    #' @param individual of interest
    #' @param ... the states of interest
    get_state = function(individual, ...) {
      states <- list(...)
      private$.simulation$get_state(individual, states)
    },

    #' @description
    #' Get a variable vector for an individual
    #' @param ... the individual and variable of interest
    get_variable = function(...) {
      private$.simulation$get_variable(...)
    },

    #' @description
    #' Schedule an event to occur in the future
    #' @param ..., forwarded to Scheduler$schedule
    schedule = function(...) {
      private$.scheduler$schedule(...)
    },

    #' @description
    #' Get the individuals who are scheduled for a particular event
    #' @param ..., forwarded to Scheduler$get_schedule
    get_scheduled = function(...) {
      private$.scheduler$get_scheduled(...)
    },

    #' @description
    #' Stop a future event from triggering for a subset of individuals
    #' @param ..., forwarded to Scheduler$clear_schedule
    clear_schedule = function(...) {
      private$.scheduler$clear_schedule(...)
    },

    #' @description
    #' Create an R wrapper for the API
    #' @param simulation, the cpp implementation of the simulation api
    initialize = function(simulation, scheduler) {
      private$.simulation <- simulation 
      private$.scheduler <- scheduler
    }
  )
)
