/*
 * SimulationFrameR.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "SimulationFrame.h"
using namespace std;
#include "Log.h"

SimulationFrame::SimulationFrame(
        shared_ptr<const states_t> states,
        shared_ptr<const variables_t> variables,
        const unsigned int current_timestep
    )
    : states(states),
      variables(variables),
      current_timestep(current_timestep)
{}

vector<size_t> SimulationFrame::get_state(
        const Environment individual,
        const List state_descriptors
    ) const {
    const auto& individual_states = *states->at(as<string>(individual["name"]))[current_timestep];
    unordered_set<size_t> result;
    for (auto it = cbegin(individual_states); it != cend(individual_states); ++it) {
        for (Environment state : state_descriptors) {
            const auto& state_set = individual_states.at(as<string>(state["name"]));
            result.insert(cbegin(state_set), cend(state_set));
        }
    }
    return vector<size_t>(cbegin(result), cend(result));
}

NumericVector SimulationFrame::get_variable(
        Environment individual,
        Environment variable
    ) const {
    Log(log_level::debug).get() << "getting variable" << endl;
    Log(log_level::debug).get() << "variable name " << as<string>(variable["name"]) << endl;
    Log(log_level::debug).get() << "individual name " << as<string>(individual["name"]) << endl;
    auto& individual_variables = variables->at(as<string>(individual["name"]));
    if (individual_variables.find(as<string>(variable["name"])) == individual_variables.end()) {
        stop("Unknown variable");
    }
    auto& variable_vector = *individual_variables.at(as<string>(variable["name"]))[current_timestep];
    return NumericVector::import(cbegin(variable_vector), cend(variable_vector));
}
