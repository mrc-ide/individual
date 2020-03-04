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
        const string individual_name,
        const vector<string> state_names
    ) const {
    auto& individual_states = *states->at(individual_name)[current_timestep];
    vector<unsigned int> result;
    for (auto it = begin(individual_states); it != end(individual_states); ++it) {
        for (auto const& state_name : state_names) {
            if (*it == state_name) {
                result.push_back(distance(begin(individual_states), it) + 1);
                break;
            }
        }
    }
    return result;
}

NumericVector SimulationFrame::get_variable(
        string individual_name,
        string variable
    ) const {
    auto& individual_variables = variables->at(individual_name);
    if (individual_variables.find(variable) == individual_variables.end()) {
        stop("Unknown variable");
    }
    auto& variable_vector = *individual_variables.at(variable)[current_timestep];
    return NumericVector::import(begin(variable_vector), end(variable_vector));
}
