#' @title EventBase Class
#' @description Common functionality shared between simple and targeted events.
#' @importFrom R6 R6Class
EventBase <- R6Class(
  'EventBase',
  public = list(
    .event = NULL,
    .listeners = list(),

    #' @description Add an event listener.
    #' @param listener the function to be executed on the event, which takes a single
    #' argument giving the time step when this event is triggered.
    add_listener = function(listener) {
      self$.listeners <- c(self$.listeners, listener)
    },

    .timestep = function() event_base_get_timestep(self$.event),

    .tick = function() event_base_tick(self$.event),

    .process = function() {
      for (listener in self$.listeners) {
        if (event_base_should_trigger(self$.event)) {
          if (inherits(listener, "externalptr")) {
            self$.process_listener_cpp(listener)
          } else {
            self$.process_listener(listener)
          }
        }
      }
    }
  )
)

#' @title Event Class
#' @description Describes a general event in the simulation.
#' @importFrom R6 R6Class
#' @export
Event <- R6Class(
  'Event',
  inherit = EventBase,
  private = list(
    should_restore = FALSE
  ),
  public = list(
    #' @description Initialise an Event.
    #' @param restore if true, the schedule of this event is restored when
    #' restoring from a saved simulation.
    initialize = function(restore = TRUE) {
      self$.event <- create_event()
      private$should_restore = restore
    },

    #' @description Schedule this event to occur in the future.
    #' @param delay the number of time steps to wait before triggering the event,
    #' can be a scalar or a vector of values for events that should be triggered
    #' multiple times.
    schedule = function(delay) {
      if (!is.null(delay)) {
        event_schedule(self$.event, delay)
      }
    },

    #' @description Stop a future event from triggering.
    clear_schedule = function() event_clear_schedule(self$.event),

    .process_listener = function(listener) {
      listener(self$.timestep())
    },

    .process_listener_cpp = function(listener) {
      process_listener(
        event = self$.event,
        listener = listener
      )
    },

    # NOTE: intentionally empty
    .resize = function() {},

    #' @description save the state of the event
    save_state = function() {
      event_checkpoint(self$.event)
    },

    #' @description restore the event from a previously saved state.
    #' If the event was constructed with \code{restore = FALSE}, the state
    #' argument is ignored.
    #' @param timestep the timestep at which simulation is resumed.
    #' @param state the previously saved state, as returned by the
    #' \code{save_state} method. NULL is passed when restoring from a saved
    #' simulation in which this variable did not exist.
    restore_state = function(timestep, state) {
      event_base_set_timestep(self$.event, timestep)
      if (private$should_restore && !is.null(state)) {
        event_restore(self$.event, state)
      }
    }
  )
)
