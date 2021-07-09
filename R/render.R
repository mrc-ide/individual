#' @title Render
#' @description Class to render output for the simulation
#' @importFrom R6 R6Class
#' @export
Render <- R6Class(
  'Render',
  private = list(
    .vectors = list(),
    .timesteps = 0
  ),
  public = list(

    #' @description
    #' Initialise a renderer for the simulation, creates the default state
    #' renderers
    #' @param timesteps number of timesteps in the simulation
    initialize = function(timesteps) {
      private$.timesteps = timesteps
      private$.vectors[['timestep']] <- seq_len(timesteps)
    },
    
    #' @description
    #' Set a default value for a rendered output
    #' renderers
    #' @param name the variable to set a default for
    #' @param value  the default value to set for a variable
    set_default = function(name, value) {
      if (name == 'timestep') {
        stop("Cannot set default value for variable 'timestep'")
      }
      private$.vectors[[name]] = rep(value, private$.timesteps)
    },

    #' @description
    #' Update the render with new simulation data
    #' @param name the variable to render
    #' @param value the value to store for the variable
    #' @param timestep the timestep of the data point
    render = function(name, value, timestep) {
      if (name == 'timestep') {
        stop("Please don't name your variable 'timestep'")
      }
      if (!(name %in% names(private$.vectors))) {
        private$.vectors[[name]] = rep(NA, private$.timesteps)
      }
      private$.vectors[[name]][[timestep]] = value
    },

    #' @description
    #' Return the render as a \code{\link[base]{data.frame}}
    to_dataframe = function() {
      data.frame(private$.vectors)
    }
  )
)
