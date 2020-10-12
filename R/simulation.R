#' @title Main simulation loop
#'
#' @param individuals a list of Individual to simulate
#' @param processes a list of processes to execute on each timestep
#' @param end_timestep the number of timesteps to simulate
#' @param parameters a list of named parameters to pass to the process functions
#' @param initialisation an optional function to initialise the model. This
#' function is passed the API, which allows you to schedule initial events
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
#'     api$queue_state_update(
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
  parameters = list(),
  initialisation = NULL
  ) {
  if (end_timestep <= 0) {
    stop('End timestep must be > 0')
  }
  if (!is.list(individuals)) {
    individuals <- list(individuals)
  }
  render <- Render$new(end_timestep)
  scheduler <- create_scheduler(individuals)
  state <- create_state(individuals)
  cpp_api <- create_process_api(state, scheduler, parameters, render)
  api <- SimAPI$new(cpp_api, parameters, render)
  if (!is.null(initialisation)) {
    execute_any_process(initialisation, api, cpp_api)
  }
  for (t in seq_len(end_timestep)) {
    for (process in processes) {
      execute_any_process(process, api, cpp_api)
    }
    scheduler_process_events(scheduler, cpp_api, api)
    state_apply_updates(state)
    scheduler_tick(scheduler)
  }
  render$to_dataframe()
}

#' @title Execute a cpp or R process in the simulation
#' @param p the process to execute
#' @param api the R api
#' @param cpp_api the C++ api
execute_any_process <- function(p, api, cpp_api) {
  if (inherits(p, "externalptr")) {
    execute_process(p, cpp_api)
  } else {
    p(api)
  }
}

#' @title Create a simulation state
#' @param individuals a list of individual objects
create_state <- function(individuals) {
  individual_names <- vcapply(individuals, function(i) i$name)
  individual_sizes <- vnapply(individuals, function (i) i$population_size)
  state <- create_cpp_state(individual_names, individual_sizes)
  for (i in individuals) {
    state_names <- vcapply(i$states, function(s) s$name)
    state_sizes <- vnapply(i$states, function(s) s$initial_size)
    state_add_states(state, i$name, state_names, state_sizes)
    for (v in i$variables) {
      state_add_variable(state, i$name, v$name, v$initial_values)
    }
  }
  state
}
