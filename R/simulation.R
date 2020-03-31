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
      private$.impl$get_api()
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
  scheduler <- Scheduler$new(end_timestep)
  api <- SimAPI$new(simulation$get_api(), scheduler)
  render$update(api, 1)
  for (timestep in seq_len(end_timestep - 1) + 1) {
    updates <- list()
    for (process in processes) {
      updates <- c(updates, process(api))
    }
    updates <- c(updates, scheduler$process_events(api))
    simulation$apply_updates(updates)
    render$update(api, timestep)
    simulation$tick()
    scheduler$tick()
  }
  render$to_dataframe()
}
