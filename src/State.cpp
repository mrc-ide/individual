/*
 * Simulation.cpp
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#include "State.h"
#include "Log.h"

State::State(const Rcpp::List individuals) :states(nullptr), variables(nullptr) {
    states = states_t();
    variables = variables_t();

    for (const Rcpp::Environment& individual : individuals) {
        auto individual_name = Rcpp::as<std::string>(individual["name"]);
        individual_names.push_back(individual_name);

        // Get the population size
        Rcpp::List state_descriptors(individual["states"]);
        auto population_size = 0;
        for (Rcpp::Environment state : state_descriptors) {
            population_size += Rcpp::as<size_t>(state["initial_size"]);
        }
        population_sizes[individual_name] = population_size;
        Log(log_level::debug).get() << "initialising " << individual_name << " x " << population_size << std::endl;

        // Initialise the initial state
        auto initial_state = state_vector_t(state_descriptors.size());
        auto start = 1;
        for (Rcpp::Environment state : state_descriptors) {
            auto size = Rcpp::as<size_t>(state["initial_size"]);
            auto state_name = Rcpp::as<std::string>(state["name"]);
            auto state_set = std::unordered_set<size_t>();
            for (auto i = start; i < start + size; ++i) {
                state_set.insert(i);
            }
            initial_state[state_name] = state_set;
            start += size;
        }

        Log(log_level::debug).get() << "initialising state container" << std::endl;
        // Initialise the state container
        states[Rcpp::as<std::string>(individual["name"])] = move(initial_state);

        Log(log_level::debug).get() << "initialising variable container" << std::endl;
        // Initialise the variable container
        Rcpp::List variable_descriptors(individual["variables"]);
        for (Rcpp::Environment variable : variable_descriptors) {
            auto variable_name = Rcpp::as<std::string>(variable["name"]);
            variable_names[individual_name].push_back(variable_name);
            Rcpp::Function initialiser(variable["initialiser"]);
            auto initial_values = Rcpp::as<variable_vector_t>(initialiser(population_size));
            variables[Rcpp::as<std::string>(individual["name"])][variable_name] = initial_values;
        }
    }
}

void State::apply_updates() {
    while(state_update_queue.size() > 0) {
        apply_state_update(state_update_queue.pop());
    }
    while(variable_update_queue.size() > 0) {
        apply_variable_update(state_update_queue.pop());
    }
}

void State::apply_state_update(const state_update_t update) {
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

void State::apply_variable_update(const variable_update_t update) {
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

individual_index_t& State::get_state(std::string individual,
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

variable_vector_t& State::get_variable(std::string individual,
    std::string variable) const {
    auto& individual_variables = variables->at(individual);
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
    const individual_index_t& index, const variable_vector_t& values) {
    variable_update_queue.push({individual, variable, index, values});
}
