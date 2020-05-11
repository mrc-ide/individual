/*
 * StateCppAPI.cpp
 *
 *  Created on: 11 May 2020
 *      Author: gc1610
 */

#include "StateCppAPI.h"

StateCppAPI::StateCppAPI(
    std::shared_ptr<const states_t> states,
    std::shared_ptr<const variables_t> variables
    )
    : states(states),
      variables(variables) {
}

individual_index_t& StateCppAPI::get_state(std::string individual,
    std::vector<std::string> states) const {
    const auto& individual_states = states->at(individual);
    individual_index_t result;
    auto added_states = std::unordered_set<std::string>();
    for (auto i = 0u; i < states.size(); ++i) {
        const auto& state_name = states[i];
        if (individual_states.find(state_name) == individual_states.end()) {
            Rcpp::stop("Unknown state");
        }
        if (states.size() == 1) {
            return individual_states.at(state_name);
        }
        if (added_states.find(state_name) == added_states.end()) {
            const auto& state_set = individual_states.at(state_name);
            result.insert(result.end(), std::cbegin(state_set), std::cend(state_set));
            added_states.insert(state_name);
        }
    }
    return result;
}

variable_vector_t& StateCppAPI::get_variable(std::string individual,
    std::string variable) const {
    auto& individual_variables = variables->at(individual);
    if (individual_variables.find(variable) == individual_variables.end()) {
        Rcpp::stop("Unknown variable");
    }
    return individual_variables.at(variable);
}
