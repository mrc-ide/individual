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

/*
 * Pre:
 *  - there exists a field that can be cast to type T from accessing `fields` in order on `e`
 */
template <class T>
T nested_accessor(Environment e, vector<string> fields) {
    auto last = fields.size() - 1;
    auto i = 0;
    while (i < last) {
        e = static_cast<Environment>(e[fields[i]]);
        ++i;
    }
    return as<T>(e[fields[i]]);
}

Simulation::Simulation(const List individuals, const int timesteps) :states(nullptr), variables(nullptr) {
    this->timesteps = timesteps;

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
        auto initial_state = make_shared<state_vector_t>(state_vector_t(population_size));
        auto start = 0;
        for (Environment state : state_descriptors) {
            auto size = as<size_t>(state["initial_size"]);
            if (size == 0) continue;
            (*initial_state)[slice(start, size, 1)] = as<string>(state["name"]);
            start += as<size_t>(state["initial_size"]);
        }

        Log(log_level::debug).get() << "state container" << endl;
        // Initialise the state container
        states = make_shared<states_t>(states_t());
        auto& state_timeline = (*states)[as<string>(individual["name"])];
        state_timeline = timeline_t<state_vector_t>(timesteps, nullptr);
        state_timeline[0] = initial_state;

        Log(log_level::debug).get() << "variable container" << endl;
        // Initialise the variable container
        variables = make_shared<variables_t>(variables_t());
        List variable_descriptors(individual["variables"]);
        for (Environment variable : variable_descriptors) {
            auto variable_name = as<string>(variable["name"]);
            variable_names[individual_name].push_back(variable_name);
            auto& variable_timeline = (*variables)[as<string>(individual["name"])][variable_name];
            variable_timeline = timeline_t<variable_vector_t>(timesteps, nullptr);
            Function initialiser(variable["initialiser"]);
            auto initial_values = to_valarray<double>(initialiser(population_size));
            variable_timeline[0] = make_shared<variable_vector_t>(initial_values);
        }
    }

}

SimulationFrame Simulation::get_current_frame() const {
    return SimulationFrame(states, variables, current_timestep);
}

void Simulation::apply_updates(const List updates) {
    // initialise next timestep
    auto next_timestep = current_timestep + 1;
    for (auto& individual_name : individual_names) {
        states->at(individual_name)[next_timestep] = states->at(individual_name)[current_timestep];
        for (auto& variable_name : variable_names[individual_name]) {
            auto& variable_timeline = variables->at(individual_name)[variable_name];
            variable_timeline[next_timestep] = variable_timeline[current_timestep];
        }
    }

    for (const Environment& update : updates) {
        auto update_type = as<string>(update["type"]);
        if (update_type == "state") {
            apply_state_update(update, next_timestep);
        } else if (update_type == "variable") {
            apply_variable_update(update, next_timestep);
        } else {
            stop("Unknown update type");
        }
    }
    current_timestep = next_timestep;
}

void Simulation::apply_state_update(const Environment update, const size_t timestep) {
    auto individual_name = nested_accessor<string>(update, {"individual", "name"});
    auto state_name = nested_accessor<string>(update, {"state", "name"});
    auto new_vector = make_shared<state_vector_t>(state_vector_t(*states->at(individual_name)[timestep]));
    auto index = static_cast<valarray<size_t>>(to_valarray<size_t>(update["index"]) - 1UL);
    (*new_vector)[index] = state_name;
    states->at(individual_name)[timestep] = new_vector;
}

void Simulation::apply_variable_update(const Environment update, const size_t timestep) {
    Log(log_level::debug).get() << "updating variable" << endl;
    auto values = to_valarray<double>(update["value"]);
    if (values.size() == 0) {
        return;
    }
    Log(log_level::debug).get() << "getting names" << endl;
    auto individual_name = nested_accessor<string>(update, {"individual", "name"});
    auto variable_name = nested_accessor<string>(update, {"variable", "name"});

    Log(log_level::debug).get() << "creating variable for " << individual_name << " " << variable_name << endl;

    shared_ptr<variable_vector_t> new_vector;
    if (static_cast<SEXP>(update["index"]) == R_NilValue) {
        // For a full vector replacement
        new_vector = make_shared<variable_vector_t>(values);
    } else {
        auto v = variable_vector_t(*variables->at(individual_name)[variable_name][timestep]);
        auto index = static_cast<valarray<size_t>>(to_valarray<size_t>(update["index"]) - 1UL);
        if (values.size() == 1) {
            // For a fill update
            v[index] = values[0];
        } else {
            // For a subarray update
            if (index.size() != values.size()) {
                stop("Subset and value size mismatch for variable " + variable_name);
            }
            v[index] = values;
        }
        new_vector = make_shared<variable_vector_t>(v);
    }
    variables->at(individual_name)[variable_name][timestep] = new_vector;
}

List Simulation::render(const Environment individual) const {
    auto name = as<string>(individual["name"]);
    return List::create(
        Named("states") = render_states(name),
        Named("variables") = render_variables(name)
    );
}

CharacterVector Simulation::render_states(const string individual_name) const {
    auto state_values = vector<string>();
    state_values.reserve(population_sizes.at(individual_name) * timesteps);
    Log(log_level::debug).get() << "timeline size " << states->at(individual_name).size() << endl;
    for(const auto& state_vector : states->at(individual_name)) {
        Log(log_level::debug).get() << "adding state vector size " << state_vector->size() << endl;
        state_values.insert(state_values.end(), cbegin(*state_vector), cend(*state_vector));
    }
    CharacterVector rendered_states = CharacterVector::import(cbegin(state_values), cend(state_values));
    rendered_states.attr("dim") = IntegerVector::create(
        static_cast<int>(population_sizes.at(individual_name)),
        static_cast<int>(timesteps)
    );
    return rendered_states;
}

NumericVector Simulation::render_variables(const string individual_name) const {
    auto variable_values = vector<double>();

    // stop early if no variables were set
    if (variable_names.find(individual_name) == variable_names.end()) {
        return NumericVector();
    }

    const auto& vnames = variable_names.at(individual_name);
    auto num_variables = vnames.size();
    variable_values.reserve(population_sizes.at(individual_name) * num_variables * timesteps);
    for(const auto& variable_name : vnames) {
        const auto& variable_timeline = variables->at(individual_name).at(variable_name);
        for(const auto& variable_vector : variable_timeline) {
            variable_values.insert(variable_values.end(), cbegin(*variable_vector), cend(*variable_vector));
        }
    }
    NumericVector rendered_variables = NumericVector::import(cbegin(variable_values), cend(variable_values));
    rendered_variables.attr("dim") = IntegerVector::create(
        static_cast<int>(population_sizes.at(individual_name)),
        static_cast<int>(num_variables),
        static_cast<int>(timesteps)
    );

    // dimnames is not trivially exposed through SEXP.attr
    Rf_setAttrib(
        rendered_variables,
        R_DimNamesSymbol,
        List::create(
            R_NilValue,
            R_NilValue,
            CharacterVector::import(cbegin(vnames), cend(vnames))
        )
    );
    return rendered_variables;
}
