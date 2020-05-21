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
  parameters=list(),
  events=list()
  ) {
  if (end_timestep <= 0) {
    stop('End timestep must be > 0')
  }
  if (!is.list(individuals)) {
    individuals <- list(individuals)
  }
  render <- Render$new(end_timestep)
  scheduler <- create_scheduler(events)
  state <- create_state(individuals)
  cpp_api <- create_process_api(state, scheduler, parameters, render)
  api <- SimAPI$new(cpp_api, parameters, render)
  for (t in seq_len(end_timestep)) {
    for (process in processes) {
      if (inherits(process, "externalptr")) {
        execute_process(process, cpp_api)
      } else {
        process(api)
      }
    }
    scheduler_process_events(scheduler, cpp_api, api)
    state_apply_updates(state)
    scheduler_tick(scheduler)
  }
  render$to_dataframe()
}
