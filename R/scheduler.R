#' Class: Scheduler
#' Class to schedule events for the simulation
Scheduler <- R6::R6Class(
  'Scheduler',
  private = list(
    .current_timestep = 1,
    .timeline = NULL
  ),
  public = list(
    #' @description
    #' Schedule an event to occur in the future
    #' @param event, the event to schedule
    #' @param target, the individuals to pass to the listener
    #' @param delay, the number of timesteps to wait before triggering the event
    schedule = function(event, target, delay) {
      if (delay < 1) {
        stop("delay must be > 0")
      }
      target_timestep <- private$.current_timestep + delay
      if (target_timestep > length(private$.timeline)) {
        return()
      }
      timestep <- private$.timeline[[target_timestep]]
      added <- FALSE
      for (i in seq_along(timestep)) {
        pair <- timestep[[i]]
        if (pair[[1]]$name == event$name) {
          private$.timeline[[target_timestep]][[i]][[2]] <- c(pair[[2]], target)
          break
        }
      }
      if (!added) {
        private$.timeline[[target_timestep]] <- c(
          timestep,
          list(list(event, target))
        )
      }
    },

    #' @description
    #' Get the individuals who are scheduled for a particular event
    #' @param event, the event of interest
    get_scheduled = function(event) {
      scheduled <- c()
      for(timestep in private$.timeline) {
        for (pair in timestep) {
          if (pair[[1]]$name == event$name) {
            scheduled <- c(scheduled, pair[[2]])
          }
        }
      }
      scheduled
    },

    #' @description
    #' Stop a future event from triggering for a subset of individuals
    #' @param event, the event to stop
    #' @param target, the individuals to clear
    clear_schedule = function(event, target) {
      for(t in seq_along(private$.timeline)) {
        for (i in seq_along(timestep)) {
          pair <- private$.timeline[[t]][[i]]
          if (pair[[1]]$name == event$name) {
            private$timeline[[t]][[i]][[2]] <- setdiff(pair[[2]], target)
          }
        }
      }
    },

    #' @description
    #' Get scheduled updates for the current timestep
    #' @param api, the api to pass to the listeners
    process_events = function(api) {
      scheduled <- private$.timeline[[private$.current_timestep]]
      updates <- list()
      for (pair in scheduled) {
        for (listener in pair[[1]]$listeners) {
          updates <- c(updates, listener(api, pair[[2]]))
        }
      }
      updates
    },

    #' @description
    #' increment the scheduler clock
    tick = function() {
      private$.current_timestep <- private$.current_timestep + 1
    },

    #' @description
    #' initialise the scheduler
    #' @param end_timestep, the number of timesteps to initialise for
    initialize = function(end_timestep) {
      private$.timeline <- vector(mode = 'list', length = end_timestep)
    }
  )
)
