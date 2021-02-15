#' @title Bernoulli process
#' @description Updates categorical variable from the `from` state to the `to`
#' state at the rate `rate`
#' @param variable a categorical variable
#' @param from a string representing the source category
#' @param to a string representing the destination category
#' @param rate the rate to move individuals between categories
#' @export
bernoulli_process <- function(variable, from, to, rate) {
  function(t) {
    variable$queue_update(
      to,
      variable$get_index_of(from)$sample(rate)
    )
  }
}

#' @title Update category listener
#' @description Updates the category of a subpopulation as the result of an
#' event being triggered
#' @param variable a categorical variable
#' @param to a string representing the destination category
#' @export
update_category_listener <- function(variable, to) {
  function(t, target) { variable$queue_update(to, target) }
}

#' @title Reschedule listener
#' @description Schedules a followup event as the result of an event
#' being triggered
#' @param event a TriggeredEvent
#' @param delay the delay until the follow-up event
#' @export
reschedule_listener <- function(event, delay) {
  function(t, target) {
    event$schedule(target, delay)
  }
}

#' @title Render Categories
#' @description Renders the number of individuals in each category
#' @param renderer your renderer object
#' @param variable a categorical variable
#' @param categories a character vector of categories to render
#' @export
categorical_count_renderer_process <- function(renderer, variable, categories) {
  function(t) {
    for (c in categories) {
      renderer$render(paste0(c, '_count'), variable$get_index_of(c)$size(), t)
    }
  }
}
