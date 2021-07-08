#' @title TargetedEvent Class
#' @description Describes a targeted event in the simulation
#' This is useful for events which are triggered for a sub-population.
#' @importFrom R6 R6Class
#' @export
TargetedEvent <- R6Class(
  'TargetedEvent',
  inherit = Event,
  public = list(
    #' @description Initialise a TargetedEvent
    #' @param population_size the size of the population
    initialize = function(population_size) {
      self$.event <- create_targeted_event(population_size)
    },

    #' @description Schedule this event to occur in the future
    #' @param target the individuals to pass to the listener, this may be 
    #' either a vector of integers or a \code{\link[individual]{Bitset}}.
    #' @param delay the number of time steps to wait before triggering the event,
    #' can be a scalar or an vector of values for events that should be triggered
    #' multiple times, fore each targeted individual.
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

    #' @description Get the individuals who are scheduled as a \code{\link[individual]{Bitset}}.
    get_scheduled = function() {
      Bitset$new(from = targeted_event_get_scheduled(self$.event))
    },

    #' @description Stop a future event from triggering for a subset of individuals
    #' @param target the individuals to clear, this may be either a vector of integers or
    #' a \code{\link[individual]{Bitset}}.
    clear_schedule = function(target) {
      if (inherits(target, "Bitset")){
        targeted_event_clear_schedule(self$.event, target$.bitset)
      } else {
        targeted_event_clear_schedule_vector(self$.event, as.integer(target))
      }
    },

    .process_listener = function(listener) {
      listener(
        event_get_timestep(self$.event),
        Bitset$new(from=targeted_event_get_target(self$.event))
      )
    },

    .process_listener_cpp = function(listener){
      individual:::process_targeted_listener(
        event = self$.event, 
        listener = listener,
        target = targeted_event_get_target(self$.event)
      )
    }

  )
)
