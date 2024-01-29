#' @title A premade simulation loop
#' @description Run a simulation where event listeners take precedence 
#' over processes for state changes.
#' @param variables a list of Variables
#' @param events a list of Events
#' @param processes a list of processes to execute on each timestep
#' @param timesteps the end timestep of the simulation. If `state` is not NULL, timesteps must be greater than `state$timestep`
#' @param state a checkpoint from which to resume the simulation
#' @param restore_random_state if TRUE, restore R's global random number generator's state from the checkpoint.
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
  timesteps,
  state = NULL,
  restore_random_state = FALSE
  ) {
  if (timesteps <= 0) {
    stop('End timestep must be > 0')
  }

  start <- 1
  if (!is.null(state)) {
    start <- restore_state(state, variables, events, restore_random_state)
    if (start > timesteps) {
      stop("Restored state is already longer than timesteps")
    }
  }

  for (t in seq(start, timesteps)) {
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
      event$.resize()
    }
    for (variable in variables) {
      variable$.resize()
    }
    for (event in events) {
      event$.tick()
    }
  }

  invisible(checkpoint_state(timesteps, variables, events))
}

#' @title Save the simulation state
#' @description Save the simulation state in an R object, allowing it to be
#' resumed later using \code{\link[individual]{restore_state}}.
#' @param timesteps <- the number of time steps that have already been simulated
#' @param variables the list of Variables
#' @param events the list of Events
checkpoint_state <- function(timesteps, variables, events) {
  random_state <- .GlobalEnv$.Random.seed
  list(
    variables=lapply(variables, function(v) v$.checkpoint()),
    events=lapply(events, function(e) e$.checkpoint()),
    timesteps=timesteps,
    random_state=random_state
  )
}

#' @title Restore the simulation state
#' @description Restore the simulation state from a previous checkpoint.
#' The state of passed events and variables is overwritten to match the state they
#' had when the simulation was checkpointed. Returns the time step at which the
#' simulation should resume.
#' @param state the simulation state to restore, as returned by \code{\link[individual]{restore_state}}.
#' @param variables the list of Variables
#' @param events the list of Events
#' @param restore_random_state if TRUE, restore R's global random number generator's state from the checkpoint.
restore_state <- function(state, variables, events, restore_random_state) {
  timesteps <- state$timesteps + 1

  if (length(variables) != length(state$variables)) {
    stop("Checkpoint's variables do not match simulation's")
  }
  for (i in seq_along(variables)) {
    variables[[i]]$.restore(state$variables[[i]])
  }

  if (length(events) != length(state$events)) {
    stop("Checkpoint's events do not match simulation's")
  }
  for (i in seq_along(events)) {
    events[[i]]$.restore(timesteps, state$events[[i]])
  }

  if (restore_random_state) {
    .GlobalEnv$.Random.seed <- state$random_state
  }

  timesteps
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
