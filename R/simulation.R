#' Class: Simulation
#' Class to store and update the simulation for each type of individual
Simulation <- R6::R6Class(
  'Simulation',
  private = list(
    .impl = NULL
  ),
  public = list(
    #' @description
    #' Return a list of the simulated states and variables for the simulation
    #' @param ... the individual to render
    render = function(...) {
      private$.impl$render(...)
    },

    #' @description
    #' Get a SimFrame for the current timestep
    get_api = function() {
      SimAPI$new(private$.impl$get_api())
    },

    #' @description
    #' Increment the timestep
    tick = function() {
      private$.impl$tick()
    },

    #' @description
    #' Perform updates on the a simulation, increment the counter and return the
    #' next simulation frame
    #' @param ... the updates as a list of update objects to apply
    apply_updates = function(...) {
      private$.impl$apply_updates(...)
    },

    #' @description
    #' Create a blank simulation and then initialize first timestep
    #' @param ... a list of Individual and the number of timesteps to
    #' initialise for
    initialize = function(...) {
      private$.impl <- new(SimulationCpp, ...)
    }
  )
)

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

#' Main simulation loop
#'
#' @param individuals a list of Individual to simulate
#' @param processes a list of processes to execute on each timestep
#' @param end_timestep the number of timesteps to simulate
#' @param custom_renderers a list of renderers to pass to Render$initialize
#' @param parameters a list of named parameters to pass to the process functions
#' @examples
#' population <- 4
#' S <- State$new('S', population)
#' I <- State$new('I', 0)
#' R <- State$new('R', 0)
#' human <- Individual$new('human', list(S, I, R))
#'
#' transition <- function(from, to, rate) {
#'   return(function(api) {
#'     from_state <- api$get_state(human, from)
#'     StateUpdate$new(
#'       human,
#'       to,
#'       from_state[runif(length(from_state), 0, 1) < rate]
#'     )
#'   })
#' }
#'
#' processes <- list(
#'   transition(S, I, .2),
#'   transition(I, R, .1),
#'   transition(R, S, .05)
#' )
#'
#' simulate(human, processes, 5)
#' @export simulate
simulate <- function(
  individuals,
  processes,
  end_timestep,
  custom_renderers=list(),
  parameters=list()
  ) {
  if (end_timestep <= 0) {
    stop('End timestep must be > 0')
  }
  if (! is.list(individuals)) {
    individuals <- list(individuals)
  }
  simulation <- Simulation$new(individuals, end_timestep)
  render <- Render$new(individuals, end_timestep, custom_renderers)
  api <- simulation$get_api()
  render$update(api, 1)
  for (timestep in seq_len(end_timestep - 1) + 1) {
    updates <- unlist(
      lapply(
        processes,
        function(process) { process(api) }
      )
    )
    simulation$apply_updates(updates)
    api <- simulation$get_api()
    render$update(api, timestep)
    simulation$tick()
  }
  render$to_dataframe()
}
