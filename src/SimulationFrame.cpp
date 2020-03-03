/*
 * SimulationFrameR.cpp
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#include "interface.h"
using namespace std;

SimulationFrame::SimulationFrame(
        List individuals,
        List states,
        List variables,
        List constants
)
    : states(states),
      constants(constants),
      variables(variables)
{}

vector<unsigned int> SimulationFrame::get_state(
        const string individual_name,
        const vector<string> state_names) {
    auto individual_states = as<vector<string>>(states[individual_name]);
    vector<unsigned int> result;
    for (auto it = individual_states.begin(); it != individual_states.end(); ++it) {
        for (auto const& state_name : state_names) {
            if (*it == state_name) {
                result.push_back(distance(individual_states.begin(), it) + 1);
                break;
            }
        }
    }
    return result;
}

NumericVector SimulationFrame::get_variable(
        string individual_name,
        string variable) {
    NumericMatrix individual_variables = variables[individual_name];
    CharacterVector variable_names = colnames(individual_variables);
    auto it = find(variable_names.begin(), variable_names.end(), variable);
    if (it == variable_names.end()) {
        stop("Unknown variable");
    }
    return individual_variables(_, distance(variable_names.begin(), it));
}
