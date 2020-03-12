/*
 * Simulation.cpp
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#include "Simulation.h"
#include "SimulationFrame.h"
#include "Log.h"

template <class T>
inline valarray<T> to_valarray(SEXP vectorsexp) {
    auto v = as<vector<T>>(vectorsexp);
    return valarray<T>(&v[0], v.size());
}

template <class T>
T nested_accessor(Environment e, vector<string> fields) {
    auto last = fields.size() - 1;
    auto i = 0;
    while (i < last) {
        SEXP next = e.get(fields[i]);
        if (next == R_NilValue) {
            stop("Malformed R6 object");
        }
        e = static_cast<Environment>(next);
        ++i;
    }
    return as<T>(e[fields[i]]);
}

inline bool any_sug(LogicalVector x){
   return is_true(any(x == TRUE));
}

inline bool is_null(SEXP x){
   return x == R_NilValue;
}

Simulation::Simulation(const List individuals, const int timesteps) :states(nullptr), variables(nullptr) {
    this->timesteps = timesteps;
    states = make_shared<states_t>(states_t());
    variables = make_shared<variables_t>(variables_t());

    for (const Environment& individual : individuals) {
        auto individual_name = as<string>(individual["name"]);
        individual_names.push_back(individual_name);

        Log(log_level::debug).get() << "pop size" << endl;
        // Get the population size
        List state_descriptors(individual["states"]);
        auto population_size = 0;
        for (Environment state : state_descriptors) {
            population_size += as<size_t>(state["initial_size"]);
        }
        population_sizes[individual_name] = population_size;

        Log(log_level::debug).get() << "initial state" << endl;
        // Initialise the initial state
        auto initial_state = state_vector_t(state_descriptors.size());
        auto start = 1;
        for (Environment state : state_descriptors) {
            auto size = as<size_t>(state["initial_size"]);
            auto state_name = as<string>(state["name"]);
            auto state_set = unordered_set<size_t>();
            for (auto i = start; i < start + size; ++i) {
                state_set.insert(i);
            }
            initial_state[state_name] = state_set;
            start += size;
        }

        Log(log_level::debug).get() << "state container" << endl;
        // Initialise the state container
        (*states)[as<string>(individual["name"])] = move(initial_state);

        Log(log_level::debug).get() << "variable container" << endl;
        // Initialise the variable container
        List variable_descriptors(individual["variables"]);
        for (Environment variable : variable_descriptors) {
            auto variable_name = as<string>(variable["name"]);
            variable_names[individual_name].push_back(variable_name);
            Function initialiser(variable["initialiser"]);
            auto initial_values = to_valarray<double>(initialiser(population_size));
            (*variables)[as<string>(individual["name"])][variable_name] = initial_values;
        }
    }
}

SimulationFrame Simulation::get_current_frame() const {
    return SimulationFrame(states, variables);
}

void Simulation::apply_updates(const List updates) {
    ++current_timestep;
    if (current_timestep == timesteps) {
        stop("We have reached the end of the simulation");
    }
    Log(log_level::debug).get() << "updating timestep: " << current_timestep << " out of: " << timesteps << endl;

    auto& new_states = *states;
    auto& new_variables = *variables;

    for (const Environment& update : updates) {
        auto update_type = as<string>(update["type"]);
        if (update_type == "state") {
            apply_state_update(update, new_states);
        } else if (update_type == "variable") {
            apply_variable_update(update, new_variables);
        } else {
            stop("Unknown update type");
        }
    }
}

void Simulation::apply_state_update(const Environment update, states_t& new_states) {
    Log(log_level::debug).get() << "updating state" << endl;
    const auto individual_name = nested_accessor<string>(update, {"individual", "name"});
    const auto state_name = nested_accessor<string>(update, {"state", "name"});
    Log(log_level::debug).get() << "state: " << individual_name << ":" << state_name << endl;
    auto index = static_cast<IntegerVector>(update["index"]);
    Log(log_level::debug).get() << index << endl;
    for (auto& pair : new_states.at(individual_name)) {
        for (auto i : index) {
            pair.second.erase(i);
        }
    }
    new_states.at(individual_name).at(state_name).insert(cbegin(index), cend(index));
}

void Simulation::apply_variable_update(const Environment update, variables_t& new_variables) {
    auto individual_name = nested_accessor<string>(update, {"individual", "name"});
    auto variable_name = nested_accessor<string>(update, {"variable", "name"});
    Log(log_level::debug).get() << "variable: " << individual_name << ":" << variable_name << endl;

    //sanity checking
    auto rvalues = static_cast<NumericVector>(update["value"]);
    if (rvalues.size() == 0) {
        return;
    }

    auto vector_replacement = is_null(update["index"]);
    auto value_fill = rvalues.size() == 1;
    auto vector_size = population_sizes.at(individual_name);
    Log(log_level::debug).get() << "replacement: " << vector_replacement << " fill: " << value_fill << endl;

    if (!vector_replacement) {
        auto rindex = static_cast<IntegerVector>(update["index"]);
        if (value_fill && rindex.size() == 0) {
            return;
        }

        if ((any_sug(rindex < 0)) || any_sug(rindex >= static_cast<int>(vector_size) + 1)) {
            stop("Index is out of bounds");
        }

        if (!value_fill && (rindex.size() != rvalues.size())) {
            stop("Index and value size mismatch");
        }
    }

    auto values = to_valarray<double>(update["value"]);
    auto& to_update = new_variables[individual_name][variable_name];

    if (vector_replacement) {
        // For a full vector replacement
        if (value_fill) {
            to_update = variable_vector_t(values[0], vector_size);
        } else {
            to_update = move(values);
        }
    } else {
        auto index = static_cast<valarray<size_t>>(to_valarray<size_t>(update["index"]) - 1UL);
        if (value_fill) {
            // For a fill update
            to_update[index] = values[0];
        } else {
            to_update[index] = values;
        }
    }
}
