#' @title A premade simulation loop
#' @description Run a simulation where event listeners take precedence 
#' over processes for state changes.
#' @param variables a list of Variables
#' @param events a list of Events
#' @param processes a list of processes to execute on each timestep
#' @param timesteps the end timestep of the simulation. If `state` is not NULL, timesteps must be greater than `state$timestep`
#' @param state a checkpoint from which to resume the simulation
#' @param restore_random_state if TRUE, restore R's global random number generator's state from the checkpoint.
#' @return Invisibly, the saved state at the end of the simulation, suitable for later resuming.
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
    start <- restore_simulation_state(state, variables, events, restore_random_state)
    if (start > timesteps) {
      stop("Restored state is already longer than timesteps")
    }
  }

  flat_events <- unlist(events)
  flat_variables <- unlist(variables)

  for (t in seq(start, timesteps)) {
    for (process in processes) {
      execute_any_process(process, t)
    }
    for (event in flat_events) {
      event$.process()
    }
    for (variable in flat_variables) {
      variable$.update()
    }
    for (event in flat_events) {
      event$.resize()
    }
    for (variable in flat_variables) {
      variable$.resize()
    }
    for (event in flat_events) {
      event$.tick()
    }
  }

  invisible(save_simulation_state(timesteps, variables, events))
}

#' @title Save the simulation state
#' @description Save the simulation state in an R object, allowing it to be
#' resumed later using \code{\link[individual]{restore_simulation_state}}.
#' @param timesteps the number of time steps that have already been simulated
#' @param variables the list of Variables
#' @param events the list of Events
#' @return the saved simulation state
save_simulation_state <- function(timesteps, variables, events) {
  random_state <- .GlobalEnv$.Random.seed
  list(
    variables=save_object_state(variables),
    events=save_object_state(events),
    timesteps=timesteps,
    random_state=random_state
  )
}

#' @title Save the state of a simulation object or set of objects.
#' @param objects a simulation object (ie. a variable or event), or list
#' thereof.
#' @return the saved states of the objects
#' @export
save_object_state <- function(objects) {
  if (is.list(objects)) {
    lapply(objects, save_object_state)
  } else {
    objects$save_state()
  }
}

#' @title Restore the simulation state
#' @description Restore the simulation state from a previous checkpoint.
#' The state of passed events and variables is overwritten to match the state
#' they had when the simulation was checkpointed.
#' @param state the simulation state to restore, as returned by
#' \code{\link[individual]{restore_simulation_state}}.
#' @param variables the list of Variables
#' @param events the list of Events
#' @param restore_random_state if TRUE, restore R's global random number
#' generator's state from the checkpoint.
#' @return  the time step at which the simulation should resume.
restore_simulation_state <- function(
  state,
  variables,
  events,
  restore_random_state) {
  timesteps <- state$timesteps + 1

  restore_object_state(timesteps, variables, state$variables)
  restore_object_state(timesteps, events, state$events)

  if (restore_random_state) {
    .GlobalEnv$.Random.seed <- state$random_state
  }

  timesteps
}

is_uniquely_named <- function(x) {
  !is.null(names(x)) && all(names(x) != "") && !anyDuplicated(names(x))
}

#' @title Restore the state of simulation objects.
#' @description Restore the state of one or more simulation objects. The
#' specified objects are paired up with the relevant part of the state object,
#' and the \code{restore_state} method of each object is called.
#'
#' If the list of object is named, more objects may be specified than were
#' originally present in the saved simulation, allowing a simulation to be
#' extended with more features upon resuming. In this case, the
#' \code{restore_state} method is called with a \code{NULL} argument.
#'
#' @param objects a simulation object (ie. a variable or event), or list
#' thereof.
#' @export
restore_object_state <- function(timesteps, objects, state) {
  if (is.list(objects)) {
    if (is.null(state)) {
      keys <- NULL
      reset <- seq_along(objects)
    } else if (is_uniquely_named(objects) && is_uniquely_named(state)) {
      missing <- setdiff(names(state), names(objects))
      if (length(missing) > 0) {
        stop(paste("Saved state contains more objects than expected:",
                   paste(missing, collapse=", ")))
      }

      keys <- names(state)
      reset <- setdiff(names(objects), names(state))
    } else if (length(state) == length(objects)) {
      keys <- seq_along(state)
      reset <- NULL
    } else {
      stop("Saved state does not match resumed objects")
    }
    for (k in keys) {
      restore_object_state(timesteps, objects[[k]], state[[k]])
    }
    for (k in reset) {
      restore_object_state(timesteps, objects[[k]], NULL)
    }
  } else {
    objects$restore_state(timesteps, state)
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
