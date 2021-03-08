#' @title Bernoulli process
#' @description Updates categorical variable from the `from` state to the `to`
#' state at the rate `rate`
#' @param variable a categorical variable
#' @param from a string representing the source category
#' @param to a string representing the destination category
#' @param rate the rate to move individuals between categories
#' @export
bernoulli_process <- function(variable, from, to, rate) {
  stopifnot(inherits(variable, "CategoricalVariable"))
  function(t) {
    variable$queue_update(
      to,
      variable$get_index_of(from)$sample(rate)
    )
  }
}

#' @title Multinomial process
#' @description Simulates a two-stage process where all individuals
#' in a given 'source_state' sample whether to leave or not with probability
#' 'rate'; those who leave go to one of the 'destination_states' with
#' probabilities contained in the vector 'destination_probabilities'.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param source_state a string representing the source state
#' @param destination_states a vector of strings representing the destination states
#' @param rate probability of individuals in source state to leave
#' @param destination_probabilities probability vector of destination states
#' @export
fixed_probability_multinomial_process <- function(variable, source_state, destination_states, rate, destination_probabilities) {
  stopifnot(length(destination_states) == length(destination_probabilities))
  stopifnot( abs(sum(destination_probabilities) - 1) <= .Machine$double.eps )
  stopifnot(inherits(variable , "CategoricalVariable"))
  return(fixed_probability_multinomial_process_internal(
    variable = variable$.variable,
    source_state = source_state,
    destination_states = destination_states,
    rate = rate,
    destination_probabilities = destination_probabilities
  ))
}

#' @title Overdispersed multinomial process
#' @description Simulates a two-stage process where all individuals
#' in a given 'source_state' sample whether to leave or not with a
#' individual probability specified by the \code{\link{DoubleVariable}}
#' object 'rate_variable'; those who leave go to one of the 'destination_states' with
#' probabilities contained in the vector 'destination_probabilities'.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param source_state a string representing the source state
#' @param destination_states a vector of strings representing the destination states
#' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
#' @param destination_probabilities probability vector of destination states
#' @export
multi_probability_multinomial_process <- function(variable, source_state, destination_states, rate_variable, destination_probabilities) {
  stopifnot(length(destination_states) == length(destination_probabilities))
  stopifnot( abs(sum(destination_probabilities) - 1) <= .Machine$double.eps )
  stopifnot(inherits(variable , "CategoricalVariable"))
  stopifnot(inherits(rate_variable , "DoubleVariable"))
  return(multi_probability_multinomial_process_internal(
    variable = variable$.variable,
    source_state = source_state,
    destination_states = destination_states,
    rate_variable = rate_variable$.variable,
    destination_probabilities = destination_probabilities
  ))
}

#' @title Overdispersed Bernoulli process
#' @description Simulates a Bernoulli process where all individuals
#' in a given source state 'from' sample whether or not 
#' to transition to destination state 'to' with a
#' individual probability specified by the \code{\link{DoubleVariable}}
#' object 'rate_variable'.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param from a string representing the source state
#' @param to a string representing the destination state
#' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
#' @export
multi_probability_bernoulli_process <- function(variable, from, to, rate_variable) {
  stopifnot(inherits(variable , "CategoricalVariable"))
  stopifnot(inherits(rate_variable , "DoubleVariable"))
  return(multi_probability_bernoulli_process_internal(
    variable = variable$.variable,
    from = from,
    to = to,
    rate_variable = rate_variable$.variable
  ))
}

#' @title Update category listener
#' @description Updates the category of a subpopulation as the result of an
#' event firing, to be used in the \code{\link[individual]{TargetedEvent}}
#' class.
#' @param variable a \code{\link[individual]{CategoricalVariable}} object
#' @param to a string representing the destination category
#' @export
update_category_listener <- function(variable, to) {
  stopifnot(inherits(variable, "CategoricalVariable"))
  function(t, target) { variable$queue_update(to, target) }
}

#' @title Reschedule listener
#' @description Schedules a followup event as the result of an event
#' firing
#' @param event a \code{\link[individual]{TargetedEvent}}
#' @param delay the delay until the follow-up event
#' @export
reschedule_listener <- function(event, delay) {
  stopifnot(inherits(event, "TargetedEvent"))
  function(t, target) {
    event$schedule(target, delay)
  }
}

#' @title Render Categories
#' @description Renders the number of individuals in each category
#' @param renderer your \code{\link[individual]{Render}} object
#' @param variable a \code{\link[individual]{CategoricalVariable}} object
#' @param categories a character vector of categories to render
#' @export
categorical_count_renderer_process <- function(renderer, variable, categories) {
  stopifnot(inherits(variable, "CategoricalVariable"))
  stopifnot(inherits(renderer, "Render"))
  function(t) {
    for (c in categories) {
      renderer$render(paste0(c, '_count'), variable$get_size_of(c), t)
    }
  }
}
