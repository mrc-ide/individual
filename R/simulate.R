#' Class: StateUpdate
#' Represents a state update
StateUpdate <- DataClass(
  'StateUpdate',
  c('individual', 'index', 'state'),

  #' @description
  #' Create a new State
  #' @param individual is the type of individual to update
  #' @param index is the index at which to apply the change
  #' @param state is the destination state of the update

  initialize = function(individual, index, state) {
    private$.individual <- individual
    private$.index <- index
    private$.state <- state
  }
)

#' Class: SimFrame
#' Represents the state of all individuals in a timestep
SimFrame <- R6::R6Class(
  'SimFrame',
  private = list(
    .frames = list()
  ),
  active = list(
    frames = readonly_accessor('frames', '.frames')
  ),
  public = list(
    #' @description
    #' Get the entire frame of an individual
    #' @param individual of interest
    get_frame = function(individual) {
      if (!(individual$name %in% names(self$frames))) {
        stop('Unregistered individual')
      }
      self$frames[[individual$name]]
    },

    #' @description
    #' Get the indecies of individuals with a particular state
    #' @param individual of interest
    #' @param state of interest
    get_state = function(individual, state) {
      individual_frame <- self$get_frame(individual)
      if (!individual$check_state(state)) {
        stop('Invalid state')
      }
      which(individual_frame$state == state$name)
    },

    #' @description
    #' Perform updates on the dataframe
    #' @param updates is a list of updates to apply
    apply_updates = function(updates) {
      for (update in updates) {
        if (class(update)[1] == 'StateUpdate') {
          private$.frames[[
            update$individual$name
          ]]$state[update$index] <- update$state$name
        }
      }
    },

    #' @description
    #' Create an initial SimFrame
    #' @param frames is a list of dataframes, one for each individual
    initialize = function(individuals) {
      if (!is.list(individuals)) {
        individuals <- list(individuals)
      }
      names <- lapply(individuals, function(i) { i$name })
      frames <- lapply(
        individuals,
        function(i) {
          levels <- vapply(i$states, function(state) {state$name}, character(1))
          data.frame(
            state = factor(
              unlist(
                lapply(i$states, function(state) {
                  rep(state$name, state$initial_size)
                })
              ),
              levels = levels
            )
          )
        }
      )
      private$.frames <- setNames(frames, names)
    }
  )
)

#' Class: Simulation
#' Representation class for a list of simframes spanning a timescale
Simulation <- R6::R6Class(
  'Simulation',
  private = list(
    .sim_frames = list()
  ),
  public = list(
    #' @description
    #' Create a simulation frame to the simulation
    #' @param frame to add
    #' @param timestep to add it to
    add_frame = function(frame, timestep) {
      private$.sim_frames[[length(private$.sim_frames) + 1]] <- list(
        frame = frame,
        timestep = timestep
      )
    },

    #' @description
    #' Create a dataframe for the entire timeline
    #' @param individual in question
    render = function(individual) {
      do.call(rbind, lapply(private$.sim_frames, function(entry) {
        individual_frame <- entry$frame$get_frame(individual)
        individual_frame$timestep <- entry$timestep
        return(individual_frame)
      }))
    },

    #' @description
    #' Create a blank simulation
    initialize = function() {
      # replace the default list
      private$.sim_frames <- list()
    }
  )
)

# Main simulation loop
simulate <- function(individuals, processes, end_timestep) {
  if (end_timestep < 0) {
    stop('End timestep must be > 0')
  }
  if (! is.list(individuals)) {
    individuals <- list(individuals)
  }
  initial_frame <- SimFrame$new(individuals)
  output <- Simulation$new()
  output$add_frame(initial_frame$clone(), 0)
  frame <- initial_frame
  if (end_timestep > 0) {
    for (timestep in seq_len(end_timestep)) {
      updates <- unlist(
        lapply(processes, function(process) { process(frame) })
      )
      if (length(updates) > 0) {
        frame$apply_updates(updates)
      }
      output$add_frame(frame$clone(), timestep)
    }
  }
  output
}
