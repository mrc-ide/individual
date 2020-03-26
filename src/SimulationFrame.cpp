/*
 * SimulationFrame.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "SimulationFrame.h"

SimulationFrame::SimulationFrame(
		std::shared_ptr<const states_t> states,
		std::shared_ptr<const variables_t> variables
    )
    : states(states),
      variables(variables)
{}

std::vector<size_t> SimulationFrame::get_state(
        const Rcpp::Environment individual,
        const Rcpp::List state_descriptors
    ) const {
    const auto& individual_states = states->at(Rcpp::as<std::string>(individual["name"]));
    std::vector<size_t> result;
    auto added_states = std::unordered_set<std::string>();
    for (Rcpp::Environment state : state_descriptors) {
        auto state_name = Rcpp::as<std::string>(state["name"]);
        if (individual_states.find(state_name) == individual_states.end()) {
            Rcpp::stop("Unknown state");
        }
        if (added_states.find(state_name) == added_states.end()) {
            const auto& state_set = individual_states.at(state_name);
            result.insert(result.end(), std::cbegin(state_set), std::cend(state_set));
            added_states.insert(state_name);
        }
    }
    return result;
}

std::vector<double> SimulationFrame::get_variable(
		Rcpp::Environment individual,
		Rcpp::Environment variable
    ) const {
    auto& individual_variables = variables->at(Rcpp::as<std::string>(individual["name"]));
    if (individual_variables.find(Rcpp::as<std::string>(variable["name"])) == individual_variables.end()) {
        Rcpp::stop("Unknown variable");
    }
    return individual_variables.at(Rcpp::as<std::string>(variable["name"]));
}
