/*
 * SimulationFrameR.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "SimulationFrame.h"
#include "Log.h"

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

vector<size_t> SimulationFrame::get_state(
        const Environment individual,
        const List state_descriptors
    ) const {
    const auto& individual_states = *states->at(as<string>(individual["name"]))[current_timestep];
    vector<size_t> result;
    auto added_states = unordered_set<string>();
    for (Environment state : state_descriptors) {
        auto state_name = as<string>(state["name"]);
        if (added_states.find(state_name) == added_states.end()) {
            const auto& state_set = individual_states.at(state_name);
            result.insert(result.end(), cbegin(state_set), cend(state_set));
            added_states.insert(state_name);
        }
    }
    return result;
}

vector<double> SimulationFrame::get_variable(
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
    return vector<double>(cbegin(variable_vector), cend(variable_vector));
}