#' Class: Event
#' Describes an event in the simulation
#' @export Event
Event <- R6::R6Class(
  'Event',
  public = list(

    #' @field name the unique name of the event
    name = '',

    #' @field listeners the listener functions to be executed when the event is
    #' triggered
    listeners = list(),

    #' @description Initialise an Event
    #' @param name, the name of the event
    initialize = function(name) {
      self$name <- name
    },

    #' @description Add an event listener
    #' @param listener the function to be executed on the event. This function
    #' should take the simulation api and target individuals as arguments
    add_listener = function(listener) {
      self$listeners <- c(self$listeners, listener)
    }
  )
)
