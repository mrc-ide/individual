#' Class: Event
#' Describes a general event in the simulation
#' @export Event
Event <- R6::R6Class(
  'Event',
  public = list(

    .event = NULL,

    #' @description Initialise an Event
    #' @param name, the name of the event
    initialize = function() {
      self$.event <- create_event()
    },

    #' @description Add an event listener
    #' @param listener the function to be executed on the event
    add_listener = function(listener) {
      event_add_listener(self$.event, listener)
    },

    #' @description schedule this event to occur in the future
    #' @param delay the number of timesteps to wait before triggering the event,
    #' can be a scalar or an vector of values for several times in the future
    schedule = function(delay) event_schedule(self$.event, delay),

    #' @description Get the individuals who are scheduled
    get_scheduled = function() {
      Bitset$new(from = event_get_scheduled(self$.event))
    },

    #' @description Stop a future event from triggering
    clear_schedule = function(event) event_clear_schedule(self$.event),

    #' @noRd
    .tick = function() event_tick(self$.event),

    #' @noRd
    .process = function() event_process(self$.event)
  )
)

#' Class: TargetedEvent
#' Describes a targeted event in the simulation
#' This is useful for events which are triggered for a sub-population
#' @export Event
TargetedEvent <- R6::R6Class(
  'TargetedEvent',
  inherit = Event,
  public = list(
    #' @description Initialise a Triggered event
    #' @param population_size the size of the target population
    initialize = function(population_size) {
      self$.event <- create_targeted_event(population_size)
    },

    #' @description schedule this event to occur in the future
    #' @param target the individuals to pass to the listener
    #' @param delay the number of timesteps to wait before triggering the event,
    #' can be a scalar or a vector of values for each target individual
    schedule = function(target, delay) {
      if (length(delay) == 1) {
        if (is.numeric(target)) {
          targeted_event_schedule_vector(self$.event, target, delay)
        } else {
          targeted_event_schedule(self$.event, target$.bitset, delay)
        }
      } else {
        if (length(target) != length(delay)) {
          stop(paste0(
            event$name,
            ' scheduled with a target which is a different size to delay'
          ))
        }
        targeted_event_schedule_multi_delay(self$.event, target, delay)
      }
    },

    #' @description Stop a future event from triggering for a subset of individuals
    #' @param target the individuals to clear
    clear_schedule = function(target) {
      if (is.numeric(target)) {
        targeted_event_clear_schedule_vector(self$.event, target)
      } else {
        targeted_event_clear_schedule(self$.event, target$.bitset)
      }
    }
  )
)
