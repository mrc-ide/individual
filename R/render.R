#' @title Render
#' @description Class to render output for the simulation.
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
    #' renderers.
    #' @param timesteps number of timesteps in the simulation.
    initialize = function(timesteps) {
      private$.timesteps <- timesteps
      private$.vectors[['timestep']] <- create_render_vector(seq_len(timesteps))
    },
    
    #' @description
    #' Set a default value for a rendered output
    #' renderers.
    #' @param name the variable to set a default for.
    #' @param value  the default value to set for a variable.
    set_default = function(name, value) {
      if (name == 'timestep') {
        stop("Cannot set default value for variable 'timestep'")
      }
      private$.vectors[[name]] <- create_render_vector(rep(value, private$.timesteps))
    },

    #' @description
    #' Update the render with new simulation data.
    #' @param name the variable to render.
    #' @param value the value to store for the variable.
    #' @param timestep the time-step of the data point.
    render = function(name, value, timestep) {
      if (name == 'timestep') {
        stop("Please don't name your variable 'timestep'")
      }
      if (!(name %in% names(private$.vectors))) {
        private$.vectors[[name]] <- create_render_vector(rep(NA_real_, private$.timesteps))
      }
      render_vector_update(private$.vectors[[name]], timestep, value)
    },

    #' @description
    #' Return the render as a \code{\link[base]{data.frame}}.
    to_dataframe = function() {
      data.frame(lapply(private$.vectors, render_vector_data))
    }
  )
)
