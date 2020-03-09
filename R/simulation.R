#' Class: Simulation
#' Class to store and update the simulation for each type of individual
Simulation <- R6::R6Class(
  'Simulation',
  private = list(
    .impl = NULL
    #.individual_to_states = list(),
    #.individual_to_variables = list(),
    #.individual_to_constants = list(),
    #.current_timestep = 1,
    #.individuals = list()
  ),
  public = list(
    #' @description
    #' Return a list of the simulated states and variables for the simulation
    #' @param individual to render
    render = function(...) {
      private$.impl$render(...)
    },

    #' @description
    #' Get a SimFrame for the current timestep
    get_current_frame = function() {
      SimFrame$new(private$.impl$get_current_frame())
    },

    #' @description
    #' Perform updates on the a simulation, increment the counter and return the
    #' next simulation frame
    #' @param updates is a list of updates to apply
    apply_updates = function(...) {
      private$.impl$apply_updates(...)
    },

    #' @description
    #' Create a blank simulation and then initialize first timestep
    #' @param individuals a list of Individual to initialise for
    #' @param timesteps the number of timesteps to initialise for
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
#' @param parameters a list of named parameters to pass to the process functions
#' @example
#' population <- 4
#' S <- State$new('S', population)
#' I <- State$new('I', 0)
#' R <- State$new('R', 0)
#' human <- Individual$new('human', list(S, I, R))
#'
#' transition <- function(from, to, rate) {
#'   return(function(frame, timestep, parameters) {
#'     from_state <- frame$get_state(human, from)
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
#' @export
simulate <- function(individuals, processes, end_timestep, parameters=list()) {
  if (end_timestep <= 0) {
    stop('End timestep must be > 0')
  }
  if (! is.list(individuals)) {
    individuals <- list(individuals)
  }
  output <- Simulation$new(individuals, end_timestep)
  frame <- output$get_current_frame()
  for (timestep in seq_len(end_timestep - 1)) {
    updates <- unlist(
      lapply(
        processes,
        function(process) { process(frame, timestep, parameters) }
      )
    )
    output$apply_updates(updates)
    frame <- output$get_current_frame()
  }
  output
}
