/*
 * Simulation.cpp
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#include "State.h"
#include "Log.h"

State::State(const sim_state_spec_t& spec) {
    states = states_t();
    variables = variables_t();

    for (const auto& individual : spec) {
        auto individual_name = std::get<0>(individual);
        individual_names.push_back(individual_name);

        // Get the population size
        auto state_descriptors = std::get<1>(individual);
        auto population_size = 0;
        for (const auto& state : state_descriptors) {
            population_size += state.second;
        }
        population_sizes[individual_name] = population_size;
        Log(log_level::debug).get() << "initialising " << individual_name << " x " << population_size << std::endl;

        // Initialise the initial state
        auto initial_state = state_vector_t(state_descriptors.size());
        auto start = 1;
        for (const auto& state : state_descriptors) {
            auto size = state.second;
            auto state_name = state.first;
            auto state_set = individual_index_t();
            for (auto i = start; i < start + size; ++i) {
                state_set.insert(i);
            }
            initial_state[state_name] = state_set;
            start += size;
        }

        Log(log_level::debug).get() << "initialising state container" << std::endl;
        // Initialise the state container
        states[individual_name] = move(initial_state);

        Log(log_level::debug).get() << "initialising variable container" << std::endl;
        // Initialise the variable container
        const auto& variable_descriptors = std::get<2>(individual);
        for (const auto& variable : variable_descriptors) {
            auto variable_name = variable.first;
            variable_names[individual_name].push_back(variable_name);
            variables[individual_name][variable_name] = variable.second;
        }
    }
}

void State::apply_updates() {
    while(state_update_queue.size() > 0) {
        apply_state_update(state_update_queue.front());
        state_update_queue.pop();
    }
    while(variable_update_queue.size() > 0) {
        apply_variable_update(variable_update_queue.front());
        variable_update_queue.pop();
    }
}

void State::apply_state_update(const state_update_t& update) {
    const auto& individual_name = std::get<0>(update);
    const auto& state_name = std::get<1>(update);
    Log(log_level::debug).get() << "updating state: " << individual_name << ":" << state_name << std::endl;
    const auto index = std::get<2>(update);
    for (auto& pair : states.at(individual_name)) {
        for (auto i : index) {
            pair.second.erase(i);
        }
    }
    states.at(individual_name).at(state_name).insert(std::cbegin(index), std::cend(index));
}

void State::apply_variable_update(const variable_update_t& update) {
    const auto& individual_name = std::get<0>(update);
    const auto& variable_name = std::get<1>(update);
    Log(log_level::debug).get() << "updating variable: " << individual_name << ":" << variable_name << std::endl;

    //sanity checking
    const auto& index = std::get<2>(update);
    const auto& values = std::get<3>(update);
    if (values.size() == 0) {
        return;
    }

    auto vector_replacement = (index.size() == 0);
    auto value_fill = (values.size() == 1);
    auto vector_size = population_sizes.at(individual_name);
    Log(log_level::debug).get() << "replacement: " << vector_replacement << " fill: " << value_fill << std::endl;

    auto& to_update = variables[individual_name][variable_name];

    if (vector_replacement) {
        // For a full vector replacement
        if (value_fill) {
            to_update = variable_vector_t(vector_size, values[0]);
        } else {
            to_update = move(values);
        }
    } else {
        if (value_fill) {
            // For a fill update
            for (auto i : index) {
              to_update[i - 1] = values[0];
            }
        } else {
            // Subset assignment
            for (auto i = 0; i < index.size(); ++i) {
              to_update[index[i] - 1] = values[i];
            }
        }
    }
}

const individual_index_t& State::get_state(
    std::string individual,
    std::string state_name) const {
    const auto& individual_states = states.at(individual);
    if (individual_states.find(state_name) == individual_states.end()) {
        Rcpp::stop("Unknown state");
    }
    return individual_states.at(state_name);
}

const variable_vector_t& State::get_variable(
    std::string individual,
    std::string variable) const {
    auto& individual_variables = variables.at(individual);
    if (individual_variables.find(variable) == individual_variables.end()) {
        Rcpp::stop("Unknown variable");
    }
    return individual_variables.at(variable);
}

void State::queue_state_update(const std::string individual, const std::string state,
    const individual_index_t& index) {
    state_update_queue.push({individual, state, index});
}

void State::queue_variable_update(const std::string individual, const std::string variable,
    const std::vector<size_t>& index, const variable_vector_t& values) {
    auto vector_replacement = (index.size() == 0);
    auto value_fill = (values.size() == 1);
    auto vector_size = population_sizes.at(individual);
    if (!vector_replacement) {
        if (value_fill && index.size() == 0) {
            return;
        }

        for (const auto i : index) {
            if (i < 0 || i > vector_size) {
                Rcpp::stop("Index is out of bounds");
            }
        }

        if (!value_fill && (index.size() != values.size())) {
            Rcpp::stop("Index and value size mismatch");
        }
    }

    variable_update_queue.push({individual, variable, index, values});
}
