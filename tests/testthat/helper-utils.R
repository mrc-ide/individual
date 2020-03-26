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
