#' @export
bernoulli_process <- function(variable, from, to, rate) {
  function(t) {
    i <- variable$get_index_of(from)
    i$sample(rate)
    variable$queue_update(to, i)
  }
}

#' @export
update_state_listener <- function(variable, to) {
  function(t, target) variable$queue_update(to, target)
}

#' @export
reschedule_listener <- function(event, delay) {
  function(t, target) {
    event$schedule(target, delay)
  }
}

#' @export
categorical_count_renderer_process <- function(renderer, variable, categories) {
  function(t) {
    for (c in categories) {
      renderer$render(paste0(c, '_count'), variable$get_index_of(c)$size(), t)
    }
  }
}
