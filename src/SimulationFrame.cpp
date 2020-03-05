/*
 * SimulationFrameR.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "SimulationFrame.h"
using namespace std;

SimulationFrame::SimulationFrame(
        shared_ptr<const states_t> states,
        shared_ptr<const variables_t> variables,
        const unsigned int current_timestep
    )
    : states(states),
      variables(variables),
      current_timestep(current_timestep)
{}

vector<unsigned int> SimulationFrame::get_state(
        const Environment individual,
        const List state_descriptors
    ) const {
    auto& individual_states = *states->at(as<string>(individual["name"]))[current_timestep];
    vector<unsigned int> result;
    for (auto it = begin(individual_states); it != end(individual_states); ++it) {
        for (auto const& state : state_descriptors) {
            if (*it == as<string>(state_descriptors["name"])) {
                result.push_back(distance(begin(individual_states), it) + 1);
                break;
            }
        }
    }
    return result;
}

NumericVector SimulationFrame::get_variable(
        Environment individual,
        Environment variable
    ) const {
    auto& individual_variables = variables->at(as<string>(individual["name"]));
    if (individual_variables.find(as<string>(variable["name"])) == individual_variables.end()) {
        stop("Unknown variable");
    }
    auto& variable_vector = *individual_variables.at(as<string>(variable["name"]))[current_timestep];
    return NumericVector::import(begin(variable_vector), end(variable_vector));
}
