mock_simulation_frame <- function(values) {
  list(
    get_state = function(individual, ...) {
      subset <- c()
      for (state in list(...)) {
        subset <- c(subset, values[[individual$name]][[state$name]])
      }
      subset
    },
    get_variable = function(individual, variable) {
      values[[individual$name]][[variable$name]]
    }
  )
}

setup_simulation <- function(
  individuals = list(),
  scheduler = NULL,
  parameters = list(),
  renderer = NULL
  ) {
  if (is.null(scheduler)) {
    scheduler <- create_scheduler(list())
  }
  if (is.null(renderer)) {
    renderer <- new.env()
  }
  state <- create_state(individuals)
  cpp_api <- create_process_api(state, scheduler, parameters, renderer)
  list(
    state = state,
    scheduler = scheduler,
    renderer = renderer,
    cpp_api = cpp_api,
    r_api = SimAPI$new(cpp_api, parameters, renderer)
  )
}
