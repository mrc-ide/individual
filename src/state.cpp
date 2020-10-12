/*
 * state.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */


#include "../inst/include/State.h"

//[[Rcpp::export]]
Rcpp::XPtr<State> create_cpp_state(
    const std::vector<std::string>& individuals,
    const std::vector<size_t>& population_sizes
    ) {
    return Rcpp::XPtr<State>(new State(individuals, population_sizes), true);
}

//[[Rcpp::export]]
void state_add_states(
    Rcpp::XPtr<State> state,
    const std::string& individual,
    const std::vector<std::string>& state_names,
    const std::vector<size_t>& initial_sizes
    ) {
    state->add_states(individual, state_names, initial_sizes);
}

//[[Rcpp::export]]
void state_add_variable(
    Rcpp::XPtr<State> state,
    const std::string& individual,
    const std::string& variable,
    const variable_vector_t& initial
    ) {
    state->add_variable(individual, variable, initial);
}

//[[Rcpp::export]]
void state_apply_updates(Rcpp::XPtr<State> state) {
    state->apply_updates();
}
