/*
 * Simulation.cpp
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#include "Simulation.h"
#include "Log.h"
#include "StateAPI.h"
#include "StateCppAPI.h"

template <class T>
T nested_accessor(Rcpp::Environment e, std::vector<std::string> fields) {
    auto last = fields.size() - 1;
    auto i = 0;
    while (i < last) {
        SEXP next = e.get(fields[i]);
        if (next == R_NilValue) {
            Rcpp::stop("Malformed object");
        }
        e = static_cast<Rcpp::Environment>(next);
        ++i;
    }
    return Rcpp::as<T>(e[fields[i]]);
}

inline bool any_sug(Rcpp::LogicalVector x){
   return is_true(Rcpp::any(x == TRUE));
}

inline bool is_null(SEXP x){
   return x == R_NilValue;
}

Simulation::Simulation(const Rcpp::List individuals, const int timesteps) :states(nullptr), variables(nullptr) {
    this->timesteps = timesteps;
    states = std::make_shared<states_t>(states_t());
    variables = std::make_shared<variables_t>(variables_t());

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
        (*states)[Rcpp::as<std::string>(individual["name"])] = move(initial_state);

        Log(log_level::debug).get() << "initialising variable container" << std::endl;
        // Initialise the variable container
        Rcpp::List variable_descriptors(individual["variables"]);
        for (Rcpp::Environment variable : variable_descriptors) {
            auto variable_name = Rcpp::as<std::string>(variable["name"]);
            variable_names[individual_name].push_back(variable_name);
            Rcpp::Function initialiser(variable["initialiser"]);
            auto initial_values = Rcpp::as<variable_vector_t>(initialiser(population_size));
            (*variables)[Rcpp::as<std::string>(individual["name"])][variable_name] = initial_values;
        }
    }
    tick();
}

StateAPI Simulation::get_state_api() const {
    return StateAPI(states, variables);
}

StateCppAPI Simulation::get_state_cpp_api() const {
    return StateCppAPI(states, variables);
}

void Simulation::tick() {
	++current_timestep;
}

void Simulation::apply_updates(const Rcpp::List updates) {
    if (current_timestep == timesteps) {
      Rcpp::stop("We have reached the end of the simulation");
    }
    Log(log_level::debug).get() << "updating timestep: " << current_timestep << " out of: " << timesteps << std::endl;

    auto& new_states = *states;
    auto& new_variables = *variables;

    for (const Rcpp::Environment& update : updates) {
        auto update_type = Rcpp::as<std::string>(update["type"]);
        if (update_type == "state") {
            apply_state_update(update, new_states);
        } else if (update_type == "variable") {
            apply_variable_update(update, new_variables);
        } else {
          Rcpp::stop("Unknown update type");
        }
    }
}

void Simulation::apply_state_update(const Rcpp::Environment update, states_t& new_states) {
    Log(log_level::debug).get() << "updating state" << std::endl;
    const auto individual_name = nested_accessor<std::string>(update, {"individual", "name"});
    const auto state_name = nested_accessor<std::string>(update, {"state", "name"});
    Log(log_level::debug).get() << "state: " << individual_name << ":" << state_name << std::endl;
    auto index = static_cast<Rcpp::IntegerVector>(update["index"]);
    for (auto& pair : new_states.at(individual_name)) {
        for (auto i : index) {
            pair.second.erase(i);
        }
    }
    new_states.at(individual_name).at(state_name).insert(std::cbegin(index), std::cend(index));
}

void Simulation::apply_variable_update(const Rcpp::Environment update, variables_t& new_variables) {
    auto individual_name = nested_accessor<std::string>(update, {"individual", "name"});
    auto variable_name = nested_accessor<std::string>(update, {"variable", "name"});
    Log(log_level::debug).get() << "variable: " << individual_name << ":" << variable_name << std::endl;

    //sanity checking
    auto rvalues = static_cast<Rcpp::NumericVector>(update["value"]);
    if (rvalues.size() == 0) {
        return;
    }

    auto vector_replacement = is_null(update["index"]);
    auto value_fill = rvalues.size() == 1;
    auto vector_size = population_sizes.at(individual_name);
    Log(log_level::debug).get() << "replacement: " << vector_replacement << " fill: " << value_fill << std::endl;

    if (!vector_replacement) {
        auto rindex = static_cast<Rcpp::IntegerVector>(update["index"]);
        if (value_fill && rindex.size() == 0) {
            return;
        }

        if ((any_sug(rindex < 0)) || any_sug(rindex >= static_cast<int>(vector_size) + 1)) {
            Rcpp::stop("Index is out of bounds");
        }

        if (!value_fill && (rindex.size() != rvalues.size())) {
            Rcpp::stop("Index and value size mismatch");
        }
    }

    auto values = Rcpp::as<std::vector<double>>(update["value"]);
    auto& to_update = new_variables[individual_name][variable_name];

    if (vector_replacement) {
        // For a full vector replacement
        if (value_fill) {
            to_update = variable_vector_t(vector_size, values[0]);
        } else {
            to_update = move(values);
        }
    } else {
        auto index = Rcpp::as<std::vector<double>>(update["index"]);
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
