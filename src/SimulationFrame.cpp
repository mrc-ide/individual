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
        shared_ptr<const variables_t> variables
    )
    : states(states),
      variables(variables)
{}

vector<size_t> SimulationFrame::get_state(
        const Environment individual,
        const List state_descriptors
    ) const {
    const auto& individual_states = states->at(as<string>(individual["name"]));
    vector<size_t> result;
    auto added_states = unordered_set<string>();
    for (Environment state : state_descriptors) {
        auto state_name = as<string>(state["name"]);
        if (individual_states.find(state_name) == individual_states.end()) {
            stop("Unknown state");
        }
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
    auto& individual_variables = variables->at(as<string>(individual["name"]));
    if (individual_variables.find(as<string>(variable["name"])) == individual_variables.end()) {
        stop("Unknown variable");
    }
    return individual_variables.at(as<string>(variable["name"]));
}
