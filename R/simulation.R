#' Class: Simulation
#' Class to store and update the simulation for each type of individual
Simulation <- R6::R6Class(
  'Simulation',
  private = list(
    .individual_to_states = list(),
    .individual_to_variables = list(),
    .individual_to_constants = list(),
    .current_timestep = 1,
    .individuals = list()
  ),
  public = list(
    #' @description
    #' Return a list of the simulated states and variables for the simulation
    #' @param individual to render
    render = function(individual) {
      list(
        states=private$.individual_to_states[[individual$name]],
        variables=private$.individual_to_variables[[individual$name]]
      )
    },

    #' @description
    #' Get a SimFrame for the current timestep
    get_current_frame = function() {
      SimFrame$new(
        private$.individuals,
        lapply(private$.individuals, function(i) {
          private$.individual_to_states[[i$name]][,private$.current_timestep]
        }),
        lapply(private$.individuals, function(i) {
          private$.individual_to_variables[[i$name]][
            ,,private$.current_timestep, drop=FALSE
          ]
        }),
        lapply(private$.individuals, function(i) {
          private$.individual_to_constants[[i$name]]
        })
      )
    },

    #' @description
    #' Perform updates on the a simulation, increment the counter and return the
    #' next simulation frame
    #' @param updates is a list of updates to apply
    apply_updates = function(updates) {

      # Copy over values to next timestep
      for (name in names(private$.individual_to_states)) {
        private$.individual_to_states[[name]][
          ,private$.current_timestep + 1
        ] <- private$.individual_to_states[[name]][,private$.current_timestep]
      }
      for (name in names(private$.individual_to_variables)) {
        private$.individual_to_variables[[name]][
          ,,private$.current_timestep + 1
        ] <- private$.individual_to_variables[[name]][
          ,,private$.current_timestep
        ]
      }

      # execute process updates
      for (update in updates) {
        if (class(update)[1] == 'StateUpdate') {
          private$.individual_to_states[[update$individual$name]][
            update$index, private$.current_timestep + 1
          ] <- update$state$name
        } else if (class(update)[1] == 'VariableUpdate') {
          private$.individual_to_variables[[update$individual$name]][
            update$index, update$variable$name ,private$.current_timestep + 1
          ] <- update$value
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
      individual_names <- lapply(individuals, function(i) { i$name })
      states <- lapply(individuals, function(i) {
        population <- sum(
          vapply(i$states, function(s) s$initial_size, numeric(1))
        )
        a <- array(
          rep(NA, population * timesteps),
          c(population, timesteps)
        )
        a[,1] <- unlist(
          lapply(i$states, function(state) {
            rep(state$name, state$initial_size)
          })
        )
        a
      })

      variables <- lapply(individuals, function(i) {
        population <- sum(
          vapply(i$states, function(s) s$initial_size, numeric(1))
        )
        n_columns <- length(i$variables)
        variable_names <- lapply(i$variables, function(v) v$name)

        a <- array(
          rep(NA, population * n_columns * timesteps),
          c(population, n_columns, timesteps)
        )

        for (j in seq_len(length(i$variables))) {
          a[,j,1] <- i$variables[[j]]$initialiser(population)
        }

        dimnames(a)[[2]] <- variable_names
        a
      })

      constants <- lapply(individuals, function(i) {
        population <- sum(
          vapply(i$states, function(s) s$initial_size, numeric(1))
        )
        n_columns <- length(i$constants)
        variable_names <- lapply(i$constants, function(v) v$name)

        a <- array(
          rep(NA, population * n_columns),
          c(population, n_columns)
        )

        for (j in seq_len(length(i$constants))) {
          a[,j] <- i$constants[[j]]$initialiser(population)
        }

        dimnames(a)[[2]] <- variable_names
        a
      })

      private$.individual_to_states <- setNames(states, individual_names)
      private$.individual_to_variables <- setNames(variables, individual_names)
      private$.individual_to_constants <- setNames(constants, individual_names)
      private$.individuals <- individuals
    }
  )
)

#' Main simulation loop
#'
#' @param individuals a list of Individual to simulate
#' @param processes a list of processes to execute on each timestep
#' @param end_timestep the number of timesteps to simulate
#' @param parameters a list of named parameters to pass to the process functions
#' @export simulate
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
    frame <- output$apply_updates(updates)
  }
  output
}
