#' Class: StateUpdate
#' Represents a state update
#' @export StateUpdate
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
    .frames = list(),
    .individuals = list(),

    #' @description
    #' Get the entire frame of an individual
    #' @param individual of interest
    .get_frame = function(individual) {
      if (!(individual$name %in% names(private$.frames))) {
        stop('Unregistered individual')
      }
      private$.frames[[individual$name]]
    }
  ),
  public = list(
    #' @description
    #' Get the indecies of individuals with a particular state
    #' @param individual of interest
    #' @param state of interest
    get_state = function(individual, state) {
      individual_frame <- private$.get_frame(individual)
      if (!individual$check_state(state)) {
        stop('Invalid state')
      }
      which(individual_frame == state$name)
    },

    #' @description
    #' Create an initial SimFrame
    #' @param individuals is a list of Individual
    #' @param arrays is a list of arrays for each individual at the current
    #' timestep
    initialize = function(individuals, arrays) {
      if (!is.list(individuals)) {
        individuals <- list(individuals)
      }
      if (!is.list(arrays)) {
        arrays <- list(arrays)
      }
      names <- lapply(individuals, function(i) { i$name })
      private$.frames <- setNames(arrays, names)
      private$.individuals <- individuals
    }
  )
)

#' Class: Simulation
#' Class to store and update the simulation for each type of individual
Simulation <- R6::R6Class(
  'Simulation',
  private = list(
    .individual_to_array = list(),
    .current_timestep = 1,
    .individuals = list()
  ),
  public = list(
    #' @description
    #' Create a dataframe for the entire timeline
    #' @param individual in question
    render = function(individual) {
      private$.individual_to_array[[individual$name]]
    },

    #' @description
    #' Get a SimFrame for the current timestep
    get_current_frame = function() {
      SimFrame$new(
        private$.individuals,
        lapply(private$.individuals, function(i) {
          private$.individual_to_array[[i$name]][,,private$.current_timestep]
        })
      )
    },

    #' @description
    #' Perform updates on the a simulation, increment the counter and return the
    #' next simulation frame
    #' @param updates is a list of updates to apply
    apply_updates = function(updates) {

      # Copy over values to next timestep
      for (name in names(private$.individual_to_array)) {
        private$.individual_to_array[[name]][
          ,,private$.current_timestep + 1
        ] <- private$.individual_to_array[[name]][,,private$.current_timestep]
      }

      # perform updates
      for (update in updates) {
        if (class(update)[1] == 'StateUpdate') {
          private$.individual_to_array[[
            update$individual$name
          ]][update$index, 1, private$.current_timestep + 1] <- update$state$name
        }
      }

      # increment timestep
      private$.current_timestep <- private$.current_timestep + 1
      self$get_current_frame()
    },

    #' @description
    #' Create a blank simulation and then initialize first timestep
    #' @param individuals a list of Individual to initialise for
    #' @param timesteps the number of timesteps to initialise for
    initialize = function(individuals, timesteps) {
      names <- lapply(individuals, function(i) { i$name })
      arrays <- lapply(individuals, function(i) {
        n <- sum(vapply(i$states, function(s) s$initial_size, numeric(1)))
        a <- array(rep(NA, n * timesteps), c(n, 1, timesteps))
        a[,1,1] <- unlist(
          lapply(i$states, function(state) {
            rep(state$name, state$initial_size)
          })
        )
        a
      })
      private$.individual_to_array <- setNames(arrays, names)
      private$.individuals <- individuals
    }
  )
)

#' Main simulation loop
#'
#' @param individuals a list of Individual to simulate
#' @param processes a list of processes to execute on each timestep
#' @param end_timestep the number of timesteps to simulate
#' @export simulate
simulate <- function(individuals, processes, end_timestep) {
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
      lapply(processes, function(process) { process(frame) })
    )
    frame <- output$apply_updates(updates)
  }
  output
}
