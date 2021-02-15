#' @title TargetedEvent Class
#' @description Describes a targeted event in the simulation
#' This is useful for events which are triggered for a sub-population
#' @export
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
        if (inherits(target, 'Bitset')) {
          target <- target$to_vector()
        }

        if (length(target) != length(delay)) {
          stop('target and delay must be the same size')
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
    },

    .process_listener = function(listener) {
      listener(
        event_get_timestep(self$.event),
        Bitset$new(from=event_get_target(self$.event))
      )
    }
  )
)
