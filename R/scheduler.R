#' Class: Scheduler
#' Class to schedule events for the simulation
Scheduler <- R6::R6Class(
  'Scheduler',
  public = list(
    #' @description
    #' Schedule an event to occur in the future
    #' @param event, the event to schedule
    #' @param target, the individuals to pass to the listener
    #' @param delay, the number of timesteps to wait before triggering the event
    schedule = function(event, target, delay) {
    },

    #' @description
    #' Get the individuals who are scheduled for a particular event
    #' @param event, the event of interest
    get_scheduled = function(event) {
    }

    #' @description
    #' Stop a future event from triggering for a subset of individuals
    #' @param event, the event to stop
    #' @param target, the individuals to clear
    clear_schedule = function(event, target) {
    },

    #' @description
    #' Apply scheduled updates for the current timestep
    process_events = function() {
    },

    #' @description
    #' increment the scheduler clock
    tick = function() {
    },

    #' @description
    #' initialise the scheduler
    #' @param individuals, the individuals to schedule for
    #' @param simulation, the simulation to update
    initialize = function(individuals, simulation, end_timestep) {
    }
  )
)
