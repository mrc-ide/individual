#' Class: SimAPI
#' The entry point for models to inspect and manipulate the simulation
SimAPI <- R6::R6Class(
  'SimAPI',
  private = list(
    .api = NULL,
    .scheduler = NULL,
    .parameters = NULL,
    .renderer = NULL
  ),
  public = list(
    #' @description Get the index of individuals with a particular state
    #' @param individual of interest
    #' @param ... the states of interest
    get_state = function(individual, ...) {
      state_names <- vcapply(unlist(list(...)), function(s) s$name)
      Bitset$new(
        from = process_get_state(
          private$.api,
          individual$name,
          individual$population_size,
          state_names
        )
      )
    },
    
    #' @description Get a variable vector for an individual
    #' @param individual the individual of interest
    #' @param variable the variable of interest
    #' @param index optionally return a subset of the variable vector
    get_variable = function(individual, variable, index=NULL) {
      if (is.null(index)) {
        return(
          process_get_variable(private$.api, individual$name, variable$name)
        )
      }
      process_get_variable_at_index(
        private$.api,
        individual$name,
        variable$name,
        index
      )
    },
    
    #' @description Queue a state update for the end of the timestep
    #' @param individual the individual of interest
    #' @param state the target state
    #' @param index the index of individuals to move to the target state
    queue_state_update = function(individual, state, index) {
      process_queue_state_update(
        private$.api,
        individual$name,
        state$name,
        index
      )
    },
    
    #' @description Queue an update for a variable. There are 4 types of variable update:
    #'
    #' 1. Subset update. The index vector represents a subset of the variable to
    #' update. The value vector, of the same size, represents the new values for
    #' that subset
    #' 2. Subset fill. The index vector represents a subset of the variable to
    #' update. The value vector, of size 1, will fill the specified subset
    #' 3. Variable reset. The index vector is set to `NULL` and the value vector
    #' replaces all of the current values in the simulation. The value vector is
    #' should match the size of the population.
    #' 4. Variable fill. The index vector is set to `NULL` and the value vector,
    #' of size 1, is used to fill all of the variable values in the population.
    #' @param individual is the type of individual to update
    #' @param variable a Variable object representing the variable to change
    #' @param values a vector or scalar of values to assign at the index
    #' @param index is the index at which to apply the change, use NULL for the
    #' fill options
    queue_variable_update = function(individual, variable, values, index=NULL) {
      if(is.null(index)){
        if(length(values) == 1){
          process_queue_variable_fill(
            private$.api,
            individual$name,
            variable$name,
            values
          )
        } else {
          process_queue_variable_update(
            private$.api,
            individual$name,
            variable$name,
            numeric(0),
            values
          )
        }
      } else if(length(index) != 0) {
        process_queue_variable_update(
          private$.api,
          individual$name,
          variable$name,
          index,
          values
        )
      }
    },
    
    #' @description Schedule an event to occur in the future
    #' @param event the event to schedule
    #' @param target the individuals to pass to the listener
    #' @param delay the number of timesteps to wait before triggering the event,
    #' can be a scalar or an array of values for each target individual
    schedule = function(event, target, delay) {
      if (length(delay) == 1) {
        process_schedule(private$.api, event$name, target, delay)
      } else {
        if (length(target) != length(delay)) {
          stop(paste0(
            event$name,
            ' scheduled with a target which is a different size to delay'
          ))
        }
        process_schedule_multi_delay(private$.api, event$name, target, delay)
      }
    },
    
    #' @description Get the individuals who are scheduled for a particular event
    #' @param event, the event of interest
    get_scheduled = function(event) {
      process_get_scheduled(private$.api, event$name)
    },
    
    #' @description Stop a future event from triggering for a subset of individuals
    #' @param event the event to stop
    #' @param target the individuals to clear
    clear_schedule = function(event, target) {
      process_clear_schedule(private$.api, event$name, target)
    },
    
    #' @description Get the current timestep of the simulation
    get_timestep = function() {
      process_get_timestep(private$.api)
    },
    
    #' @description Get the parameters of the simulation
    get_parameters = function() {
      private$.parameters
    },
    
    #' @description Add a value for the simulation output
    #' @param name the column name
    #' @param value the value to assign
    #' @param timestep optionally add the value to a specific timestep
    render = function(name, value, timestep=NULL) {
      if (is.null(timestep)) {
        timestep <- self$get_timestep()
      }
      private$.renderer$add(name, value, timestep)
    },
    
    #' @description Create an R wrapper for the API
    #' @param cpp_api the cpp implementation of the simulation api
    #' @param parameters model parameters
    #' @param renderer renderer to store model outputs to
    initialize = function(cpp_api, parameters, renderer) {
      private$.api <- cpp_api
      private$.parameters <- parameters
      private$.renderer <- renderer
    }
  )
)
