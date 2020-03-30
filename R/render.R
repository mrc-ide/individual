#' Class: Render
#' Class to render output for the simulation
Render <- R6::R6Class(
  'Render',
  private = list(
    .vectors = list(),
    .renderers = list(),
    .timesteps = 0,
    .state_renderer = function(individuals) {
      function(frame) {
        values = list()
        for (individual in individuals) {
          for (state in individual$states) {
            colname <- paste(individual$name, '_', state$name, '_count', sep='')
            values[[colname]] <- length(
              frame$get_state(individual, state)
            )
          }
        }
        values
      }
    }
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
    initialize = function(individuals, timesteps, renderers = list()) {
      private$.renderers <- c(
        private$.state_renderer(individuals),
        renderers
      )
      private$.timesteps = timesteps
      private$.vectors[['timestep']] <- seq_len(timesteps)
    },

    #' @description
    #' Update the render with new simulation data
    #' @param frame the new SimFrame
    #' @param timestep the timestep of the frame
    update = function(frame, timestep) {
      for (renderer in private$.renderers) {
        values <- renderer(frame)
        for (name in names(values)) {
          if (timestep == 1) {
            private$.vectors[[name]] = rep(NA, private$.timesteps)
          }
          private$.vectors[[name]][[timestep]] = values[[name]]
        }
      }
    },
    #' @description
    #' Make a dataframe for the render
    to_dataframe = function() {
      data.frame(private$.vectors)
    }
  )
)
