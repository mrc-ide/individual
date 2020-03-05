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
    render = function(individual) {
      #list(
        #states=private$.individual_to_states[[individual$name]],
        #variables=private$.individual_to_variables[[individual$name]]
      #)
    },

    #' @description
    #' Get a SimFrame for the current timestep
    get_current_frame = function() {
      SimFrame$new(private$.impl$get_current_frame())
      #SimFrame$new(
        #private$.individuals,
        #lapply(private$.individuals, function(i) {
          #private$.individual_to_states[[i$name]][,private$.current_timestep]
        #}),
        #lapply(private$.individuals, function(i) {
          #values <- private$.individual_to_variables[[i$name]][
            #,,private$.current_timestep, drop=FALSE
          #]
          #m <- matrix(values, dim(values)[1:2])
          #colnames(m) <-dimnames(values)[[2]]
          #m
        #}),
        #lapply(private$.individuals, function(i) {
          #values <- private$.individual_to_constants[[i$name]]
          #m <- matrix(values, dim(values))
          #colnames(m) <-dimnames(values)[[2]]
          #m
        #})
      #)
    },

    #' @description
    #' Perform updates on the a simulation, increment the counter and return the
    #' next simulation frame
    #' @param updates is a list of updates to apply
    apply_updates = function(updates) {

      # Copy over values to next timestep
      #for (name in names(private$.individual_to_states)) {
        #private$.individual_to_states[[name]][
          #,private$.current_timestep + 1
        #] <- private$.individual_to_states[[name]][,private$.current_timestep]
      #}
      #for (name in names(private$.individual_to_variables)) {
        #private$.individual_to_variables[[name]][
          #,,private$.current_timestep + 1
        #] <- private$.individual_to_variables[[name]][
          #,,private$.current_timestep
        #]
      #}

      ## execute process updates
      #for (update in updates) {
        #if (inherits(update, 'StateUpdate')) {
          #private$.individual_to_states[[update$individual$name]][
            #update$index, private$.current_timestep + 1
          #] <- update$state$name
        #} else if (inherits(update, 'VariableUpdate')) {
          #private$.individual_to_variables[[update$individual$name]][
            #update$index, update$variable$name ,private$.current_timestep + 1
          #] <- update$value
        #}
      #}

      ## increment timestep
      #private$.current_timestep <- private$.current_timestep + 1
      #self$get_current_frame()
    },

    #' @description
    #' Create a blank simulation and then initialize first timestep
    #' @param individuals a list of Individual to initialise for
    #' @param timesteps the number of timesteps to initialise for
    initialize = function(individuals, timesteps) {
      private$.impl <- new(SimulationCpp, individuals, timesteps)
      #states <- lapply(individuals, function(i) {
        #population <- sum(
          #vnapply(i$states, function(s) s$initial_size)
        #)
        #a <- array(
          #rep(NA, population * timesteps),
          #c(population, timesteps)
        #)
        #a[,1] <- rep(
          #vcapply(i$states, function(x) x$name),
          #vnapply(i$states, function(x) x$initial_size)
        #)
        #a
      #})

      #variables <- lapply(individuals, function(i) {
        #population <- sum(
          #vnapply(i$states, function(s) s$initial_size)
        #)
        #n_columns <- length(i$variables)
        #variable_names <- lapply(i$variables, function(v) v$name)

        #a <- array(
          #rep(NA, population * n_columns * timesteps),
          #c(population, n_columns, timesteps)
        #)

        #for (j in seq_len(n_columns)) {
          #a[,j,1] <- i$variables[[j]]$initialiser(population)
        #}

        #dimnames(a)[[2]] <- variable_names
        #a
      #})

      #constants <- lapply(individuals, function(i) {
        #population <- sum(
          #vnapply(i$states, function(s) s$initial_size)
        #)
        #n_columns <- length(i$constants)
        #variable_names <- lapply(i$constants, function(v) v$name)

        #a <- array(
          #rep(NA, population * n_columns),
          #c(population, n_columns)
        #)

        #for (j in seq_len(length(i$constants))) {
          #a[,j] <- i$constants[[j]]$initialiser(population)
        #}

        #dimnames(a)[[2]] <- variable_names
        #a
      #})

      #private$.individual_to_states <- setNames(states, individual_names)
      #private$.individual_to_variables <- setNames(variables, individual_names)
      #private$.individual_to_constants <- setNames(constants, individual_names)
      #private$.individuals <- individuals
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
    frame <- output$apply_updates(updates)
  }
  output
}
