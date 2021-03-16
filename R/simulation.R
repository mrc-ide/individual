#' @title A premade simulation loop
#' @description Run a simulation where event listeners take precedence 
#' over processes for state changes.
#' @param variables a list of Variables
#' @param events a list of Events
#' @param processes a list of processes to execute on each timestep
#' @param timesteps the number of timesteps to simulate
#' @examples
#' population <- 4
#' timesteps <- 5
#' state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
#' renderer <- Render$new(timesteps)
#'
#' transition <- function(from, to, rate) {
#'   return(function(t) {
#'     from_state <- state$get_index_of(from)
#'     state$queue_update(
#'       to,
#'       from_state$sample(rate)
#'     )
#'   })
#' }
#'
#' processes <- list(
#'   transition('S', 'I', .2),
#'   transition('I', 'R', .1),
#'   transition('R', 'S', .05),
#'   categorical_count_renderer_process(renderer, state, c('S', 'I', 'R'))
#' )
#'
#' simulation_loop(variables=list(state), processes=processes, timesteps=timesteps)
#' renderer$to_dataframe()
#' @export
simulation_loop <- function(
  variables = list(),
  events = list(),
  processes = list(),
  timesteps
  ) {
  if (timesteps <= 0) {
    stop('End timestep must be > 0')
  }
  for (t in seq_len(timesteps)) {
    for (process in processes) {
      execute_any_process(process, t)
    }
    for (event in events) {
      event$.process()
    }
    for (variable in variables) {
      variable$.update()
    }
    for (event in events) {
      event$.tick()
    }
  }
}

#' @title Execute a C++ or R process in the simulation
#' @param p the process to execute
#' @param t the timestep to pass to the process
#' @noRd
execute_any_process <- function(p, t) {
  if (inherits(p, "externalptr")) {
    execute_process(p, t)
  } else {
    p(t)
  }
}
