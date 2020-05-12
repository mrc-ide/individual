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
  render <- Render$new(individuals, end_timestep, custom_renderers)
  scheduler <- Scheduler$new(end_timestep)
  state <- create_state(individuals)
  api <- SimAPI$new(state, scheduler, parameters)
  render$update(api, 1)
  for (timestep in seq_len(end_timestep - 1) + 1) {
    for (process in processes) {
      updates <- process(api)
      queue_updates(api, updates)
    }
    scheduler$process_events(api)
    state_apply_updates(state)
    render$update(api, timestep)
    scheduler$tick()
  }
  render$to_dataframe()
}
