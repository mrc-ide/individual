#' @title Event Class
#' @description Describes a general event in the simulation
#' @export
Event <- R6::R6Class(
  'Event',
  public = list(

    .event = NULL,
    .listeners = list(),

    #' @description Initialise an Event
    #' @param name, the name of the event
    initialize = function() {
      self$.event <- create_event()
    },

    #' @description Add an event listener
    #' @param listener the function to be executed on the event
    add_listener = function(listener) {
      self$.listeners <- c(self$.listeners, listener)
    },

    #' @description schedule this event to occur in the future
    #' @param delay the number of timesteps to wait before triggering the event,
    #' can be a scalar or an vector of values for several times in the future
    schedule = function(delay) event_schedule(self$.event, delay),

    #' @description Stop a future event from triggering
    clear_schedule = function() event_clear_schedule(self$.event),
  
    .tick = function() event_tick(self$.event),

    .process = function() {
      for (listener in self$.listeners) {
        if (event_should_trigger(self$.event)) {
          if (inherits(listener, "externalptr")) {
            self$.process_listener_cpp(self$.event, listener)
          } else {
            self$.process_listener(listener)
          }
        }
      }
    },

    .process_listener = function(listener) {
      listener(event_get_timestep(self$.event))
    },

    .process_listener_cpp = function(listener){
      individual:::process_listener(
        event = self$.event, 
        listener = listener
      )
    }

  )
)
