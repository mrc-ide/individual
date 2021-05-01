#' @title Bernoulli process
#' @description Simulate a process where individuals in a given \code{from} state
#' advance to the \code{to} state each time step with probability \code{rate}.
#' @param variable a categorical variable
#' @param from a string representing the source category
#' @param to a string representing the destination category
#' @param rate the probability to move individuals between categories
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
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
#' in a given \code{source_state} sample whether to leave or not with probability
#' \code{rate}; those who leave go to one of the \code{destination_states} with
#' probabilities contained in the vector \code{destination_probabilities}.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param source_state a string representing the source state
#' @param destination_states a vector of strings representing the destination states
#' @param rate probability of individuals in source state to leave
#' @param destination_probabilities probability vector of destination states
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
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
#' in a given \code{source_state} sample whether to leave or not with a
#' individual probability specified by the \code{\link{DoubleVariable}}
#' object \code{rate_variable}; those who leave go to one of the \code{destination_states} with
#' probabilities contained in the vector \code{destination_probabilities}.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param source_state a string representing the source state
#' @param destination_states a vector of strings representing the destination states
#' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
#' @param destination_probabilities probability vector of destination states
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
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
#' in a given source state \code{from} sample whether or not 
#' to transition to destination state \code{to} with a
#' individual probability specified by the \code{\link{DoubleVariable}}
#' object \code{rate_variable}.
#' @param variable a \code{\link{CategoricalVariable}} object
#' @param from a string representing the source state
#' @param to a string representing the destination state
#' @param rate_variable \code{\link{DoubleVariable}} giving individual probability of each individual in source state to leave
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
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

#' @title Infection process for age-structured models
#' @description Simulates infection for age-structured models, where
#' individuals contact each other at a rate given by some mixing (contact) matrix.
#' The force of infection on susceptibles in a given age class is computed as:
#' \deqn{\lambda_{i} = p \sum\limits_{j} C_{i,j} \left( \frac{I_{j}}{N_{j}} \right)  }
#' Where \eqn{C} is the matrix of contact rates, \eqn{p} is the probability of infection
#' per contact. The per-capita probability of infection for susceptible individuals is then:
#' \deqn{1 - e^{-\lambda_{i} \Delta t}}
#' @param state a \code{\link{CategoricalVariable}} object
#' @param susceptible a string representing the susceptible state (usually "S")
#' @param exposed a string representing the state new infections go to (usually "E" or "I")
#' @param infectious a string representing the infected and infectious  state (usually "I")
#' @param age a \code{\link{IntegerVariable}} giving the age of each individual 
#' @param age_bins the total number of age bins (groups)
#' @param p the probability of infection given a contact
#' @param dt the size of the time step (in units relative to the contact rates in \code{mixing})
#' @param mixing a mixing (contact) matrix between age groups 
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
#' @export
infection_age_process <- function(state, susceptible, exposed, infectious, age, age_bins, p, dt, mixing) {
  stopifnot( all(dim(mixing) == age_bins) )
  stopifnot( inherits(state, "CategoricalVariable") )
  stopifnot( inherits(age, "IntegerVariable") )
  return(
    infection_age_process_internal(
      state = state$.variable,
      susceptible = as.character(susceptible),
      exposed = as.character(exposed),
      infectious = as.character(infectious),
      age = age$.variable,
      age_bins = as.integer(age_bins),
      p = as.numeric(p),
      dt = as.numeric(dt),
      mixing = mixing
    )
  )
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
#' @param renderer a \code{\link[individual]{Render}} object
#' @param variable a \code{\link[individual]{CategoricalVariable}} object
#' @param categories a character vector of categories to render
#' @return a function which can be passed as a process to \code{\link{simulation_loop}}
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
