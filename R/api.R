#' Class: SimAPI
#' The entry point for models to inspect and manipulate the simulation
SimAPI <- R6::R6Class(
  'SimAPI',
  private = list(
    .api = NULL,
    .scheduler = NULL,
    .parameters = NULL,
    .renderer = NULL
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
    get_variable = function(individual, variable, index=NULL) {
      if (is.null(index)) {
        return(
          process_get_variable(private$.api, individual$name, variable$name)
        )
      }
      process_get_variable_at_index(
        private$.api,
        individual$name,
        variable$name,
        index - 1
      )
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
    queue_variable_update = function(individual, variable, values, index=numeric(0)) {
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
    #' @param event, the event to schedule
    #' @param target, the individuals to pass to the listener
    #' @param delay, the number of timesteps to wait before triggering the event
    schedule = function(event, target, delay) {
      process_schedule(private$.api, event$name, target, delay)
    },

    #' @description
    #' Get the individuals who are scheduled for a particular event
    #' @param event, the event of interest
    get_scheduled = function(event) {
      process_get_scheduled(private$.api, event$name)
    },

    #' @description
    #' Stop a future event from triggering for a subset of individuals
    #' @param event, the event to stop
    #' @param target, the individuals to clear
    clear_schedule = function(event, target) {
      process_clear_schedule(private$.api, event$name, target)
    },

    #' @description
    #' Get the current timestep of the simulation
    get_timestep = function() {
      process_get_timestep(private$.api)
    },

    #' @description
    #' Get the parameters of the simulation
    get_parameters = function() {
      private$.parameters
    },

    #' @description
    #' Get the parameters of the simulation
    render = function(name, value, timestep=NULL) {
      if (is.null(timestep)) {
        timestep <- self$get_timestep()
      }
      private$.renderer$add(name, value, timestep)
    },

    #' @description
    #' Create an R wrapper for the API
    #' @param cpp_api, the cpp implementation of the simulation api
    #' @param parameters, model parameters
    #' @param renderer, renderer to store model outputs to
    initialize = function(cpp_api, parameters, renderer) {
      private$.api <- cpp_api
      private$.parameters <- parameters
      private$.renderer <- renderer
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
          update$value,
          update$index
        )
      }
    }
  }
}
