/*
 * state.h
 *
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_STATE_H_
#define INST_INCLUDE_STATE_H_

#include <unordered_set>
#include <tuple>
#include <queue>
#include "common_types.h"
#include "Log.h"

using individual_index_t = std::unordered_set<size_t>;
using variable_vector_t = std::vector<double>;
using state_vector_t = named_array_t<individual_index_t>;

using states_t = named_array_t<state_vector_t>;
using variables_t = named_array_t<named_array_t<variable_vector_t>>;
using state_update_t = std::tuple<std::string, std::string, individual_index_t>;
using variable_update_t = std::tuple<std::string, std::string, std::vector<size_t>, variable_vector_t>;

using variable_spec_t = std::pair<std::string, std::vector<double>>;
using state_spec_t = std::pair<std::string, size_t>;
using individual_spec_t = std::tuple<std::string, std::vector<state_spec_t>, std::vector<variable_spec_t>>;
using sim_state_spec_t = std::vector<individual_spec_t>;

class State {
    states_t states;
    variables_t variables;
    std::vector<std::string> individual_names;
    named_array_t<std::vector<std::string>> variable_names;
    named_array_t<size_t> population_sizes;
    std::queue<state_update_t> state_update_queue;
    std::queue<variable_update_t> variable_update_queue;
    void apply_state_update(const state_update_t&);
    void apply_variable_update(const variable_update_t&);
public:
    State(const sim_state_spec_t&);
    void apply_updates();
    const individual_index_t& get_state(const std::string&, const std::string&) const;
    const variable_vector_t& get_variable(const std::string&, const std::string&) const;
    void get_variable(
        const std::string&,
        const std::string&,
        const std::vector<size_t>&,
        std::vector<double>&
        ) const;
    void queue_state_update(const std::string&, const std::string&, const individual_index_t&);
    void queue_variable_update(const std::string&, const std::string&, const std::vector<size_t>&, const variable_vector_t&);
};

inline State::State(const sim_state_spec_t& spec) {
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

inline void State::apply_updates() {
    while(state_update_queue.size() > 0) {
        apply_state_update(state_update_queue.front());
        state_update_queue.pop();
    }
    while(variable_update_queue.size() > 0) {
        apply_variable_update(variable_update_queue.front());
        variable_update_queue.pop();
    }
}

inline void State::apply_state_update(const state_update_t& update) {
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

inline void State::apply_variable_update(const variable_update_t& update) {
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

inline const individual_index_t& State::get_state(
    const std::string& individual,
    const std::string& state_name) const {
    const auto& individual_states = states.at(individual);
    if (individual_states.find(state_name) == individual_states.end()) {
        Rcpp::stop("Unknown state");
    }
    return individual_states.at(state_name);
}

inline const variable_vector_t& State::get_variable(
    const std::string& individual,
    const std::string& variable) const {
    auto& individual_variables = variables.at(individual);
    if (individual_variables.find(variable) == individual_variables.end()) {
        Rcpp::stop("Unknown variable");
    }
    return individual_variables.at(variable);
}

inline void State::get_variable(
    const std::string& individual,
    const std::string& variable,
    const std::vector<size_t>& index,
    std::vector<double>& result) const {
    auto& individual_variables = variables.at(individual);
    if (individual_variables.find(variable) == individual_variables.end()) {
        Rcpp::stop("Unknown variable");
    }
    const auto& v = individual_variables.at(variable);
    result.resize(index.size());
    for (auto i = 0u; i < index.size(); ++i) {
        if (index[i] < v.size()) {
            result[i] = v[index[i]];
        } else {
            Rcpp::stop("Invalid index for variable");
        }
    }
}

inline void State::queue_state_update(const std::string& individual, const std::string& state,
    const individual_index_t& index) {
    state_update_queue.push({individual, state, index});
}

inline void State::queue_variable_update(const std::string& individual, const std::string& variable,
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

#endif /* INST_INCLUDE_STATE_H_ */
