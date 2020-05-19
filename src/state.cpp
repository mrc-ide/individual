/*
 * state.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */


#include "../inst/include/State.h"

//[[Rcpp::export]]
Rcpp::XPtr<State> create_state(const Rcpp::List individuals) {
    auto sim_state_spec = sim_state_spec_t();
    for (const Rcpp::Environment& individual : individuals) {
        auto individual_name = Rcpp::as<std::string>(individual["name"]);
        auto state_spec = std::vector<state_spec_t>();
        auto pop_size = 0u;
        Rcpp::List state_descriptors(individual["states"]);
        for (Rcpp::Environment state : state_descriptors) {
            auto state_size = Rcpp::as<size_t>(state["initial_size"]);
            pop_size += state_size;
            state_spec.push_back({
                Rcpp::as<std::string>(state["name"]),
                state_size
            });
        }

        auto variable_spec = std::vector<variable_spec_t>();
        Rcpp::List variable_descriptors(individual["variables"]);
        for (Rcpp::Environment variable : variable_descriptors) {
            Rcpp::Function initialiser(variable["initialiser"]);
            auto initial_values = Rcpp::as<variable_vector_t>(initialiser(pop_size));
            variable_spec.push_back({
                Rcpp::as<std::string>(variable["name"]),
                initial_values
            });
        }
        sim_state_spec.push_back({individual_name, state_spec, variable_spec});
    }
    auto state = new State(sim_state_spec);
    return Rcpp::XPtr<State>(state, true);
}

//[[Rcpp::export]]
void state_apply_updates(Rcpp::XPtr<State> state) {
    state->apply_updates();
}
