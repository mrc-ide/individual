#' Class: SimAPI
#' The entry point for models to inspect and manipulate the simulation
SimAPI <- R6::R6Class(
  'SimAPI',
  private = list(
    .api = NULL,
    .scheduler = NULL,
    .parameters = NULL
  ),
  public = list(
    #' @description
    #' Get the index of individuals with a particular state
    #' @param individual of interest
    #' @param ... the states of interest
    get_state = function(individual, ...) {
      state_names <- vcapply(unlist(list(...)), function(s) s$name)
      process_get_state(private$.api, individual$name, state_names)
    },

    #' @description
    #' Get a variable vector for an individual
    #' @param individual the individual of interest
    #' @param variable the variable of interest
    get_variable = function(individual, variable) {
      process_get_variable(private$.api, individual$name, variable$name)
    },

    #' @description
    #' Queue a state update for the end of the timestep
    #' @param individual the individual of interest
    #' @param state the target state
    #' @param index the index of individuals to move to the target state
    queue_state_update = function(individual, state, index) {
      process_queue_state_update(
        private$.api,
        individual$name,
        state$name,
        index
      )
    },

    #' @description
    #' Queue a variable update for the end of the timestep
    #' @param individual the individual of interest
    #' @param variable the variable to update
    #' @param index the index of individuals to update
    #' @param values the values to apply at index
    queue_variable_update = function(individual, variable, index, values) {
      process_queue_variable_update(
        private$.api,
        individual$name,
        variable$name,
        index,
        values
      )
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
    #' Get the current timestep of the simulation
    get_timestep = function() {
      private$.scheduler$get_timestep()
    },

    #' @description
    #' Get the parameters of the simulation
    get_parameters = function() {
      private$.parameters
    },

    #' @description
    #' Create an R wrapper for the API
    #' @param simulation, the cpp implementation of the simulation api
    #' @param scheduler, the implementation of the scheduler interface
    initialize = function(state, scheduler, parameters) {
      private$.api <- create_process_api(state, scheduler, parameters)
      private$.scheduler <- scheduler
      private$.parameters <- parameters
    }
  )
)

#' @description
#' A utility function to queue updates that are returned from processes
#' @param api, the interface to the simulation state
#' @param updates, the list of updates to enqueue
queue_updates <- function(api, updates) {
  if (!is.null(updates)) {
    if(!is.vector(updates)) {
      updates <- list(updates)
    }
    for (update in updates) {
      if (update$type == 'state') {
        api$queue_state_update(update$individual, update$state, update$index)
      } else if (update$type == 'variable') {
        api$queue_variable_update(
          update$individual,
          update$variable,
          update$index,
          update$value
        )
      }
    }
  }
}
