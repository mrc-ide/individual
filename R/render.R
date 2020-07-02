#' Class: Render
#' Class to render output for the simulation
Render <- R6::R6Class(
  'Render',
  private = list(
    .vectors = list(),
    .timesteps = 0
  ),
  public = list(
    #' @description
    #' Initialise a renderer for the simulation, creates the default state
    #' renderers
    #' @param individuals to render states for
    #' @param timesteps number of timesteps in the simulation
    #' @param renderers additional renderers to execute. Renderers are functions
    #' which take a SimFrame as an argument and return a list of
    #' scalar outputs to store to the final render
    initialize = function(timesteps) {
      private$.timesteps = timesteps
    },

    #' @description
    #' Update the render with new simulation data
    #' @param name the variable to render
    #' @param value the value to store for the variable
    #' @param timestep the timestep of the data point
    add = function(name, value, timestep) {
      if (name == 'timestep') {
        stop("Please don't name your variable 'timestep'")
      }
      if (!(name %in% names(private$.vectors))) {
        if (length(value) == 1) {
          private$.vectors[[name]] = rep(NA, private$.timesteps)
        } else {
          private$.vectors[[name]] = as.list(rep(NA, private$.timesteps))
        }
      }
      private$.vectors[[name]][[timestep]] = value
    },

    #' @description
    #' Make a dataframe for the render
    to_dataframe = function() {
      df <- data.frame(timestep = seq_len(private$.timesteps))
      for (k in names(private$.vectors)) {
        df[[k]] <- private$.vectors[[k]]
      }
      df
    }
  )
)
