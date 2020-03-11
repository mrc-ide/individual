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
   // Note the use of is_true to return a bool type
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
        auto initial_state = make_shared<state_vector_t>(state_vector_t(state_descriptors.size()));
        auto start = 1;
        for (Environment state : state_descriptors) {
            auto size = as<size_t>(state["initial_size"]);
            auto state_set = unordered_set<size_t>();
            for (auto i = start; i < start + size; ++i) {
                state_set.insert(i);
            }
            (*initial_state)[as<string>(state["name"])] = state_set;
            start += size;
        }

        Log(log_level::debug).get() << "state container" << endl;
        // Initialise the state container
        auto& state_timeline = (*states)[as<string>(individual["name"])];
        state_timeline = timeline_t<state_vector_t>(timesteps, nullptr);
        state_timeline[current_timestep] = initial_state;

        Log(log_level::debug).get() << "variable container" << endl;
        // Initialise the variable container
        List variable_descriptors(individual["variables"]);
        for (Environment variable : variable_descriptors) {
            auto variable_name = as<string>(variable["name"]);
            variable_names[individual_name].push_back(variable_name);
            auto& variable_timeline = (*variables)[as<string>(individual["name"])][variable_name];
            variable_timeline = timeline_t<variable_vector_t>(timesteps, nullptr);
            Function initialiser(variable["initialiser"]);
            auto initial_values = to_valarray<double>(initialiser(population_size));
            variable_timeline[current_timestep] = make_shared<variable_vector_t>(initial_values);
        }
    }
}

SimulationFrame Simulation::get_current_frame() const {
    return SimulationFrame(states, variables, current_timestep);
}

void Simulation::apply_updates(const List updates) {
    // initialise next timestep
    auto next_timestep = current_timestep + 1;
    if (next_timestep == timesteps) {
        stop("We have reached the end of the simulation");
    }
    Log(log_level::debug).get() << "updating timestep: " << next_timestep << " out of: " << timesteps << endl;

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
    Log(log_level::debug).get() << "updating state" << endl;
    const auto individual_name = nested_accessor<string>(update, {"individual", "name"});
    const auto state_name = nested_accessor<string>(update, {"state", "name"});
    Log(log_level::debug).get() << "state: " << individual_name << ":" << state_name << endl;
    const auto new_vector = make_shared<state_vector_t>(state_vector_t(*states->at(individual_name)[timestep]));
    auto index = static_cast<IntegerVector>(update["index"]);
    Log(log_level::debug).get() << index << endl;
    for (auto& pair : *new_vector) {
        for (auto i : index) {
            pair.second.erase(i);
        }
    }
    (*new_vector)[state_name].insert(cbegin(index), cend(index));
    states->at(individual_name)[timestep] = new_vector;
}

void Simulation::apply_variable_update(const Environment update, const size_t timestep) {
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

    shared_ptr<variable_vector_t> new_vector;
    if (vector_replacement) {
        // For a full vector replacement
        if (value_fill) {
            new_vector = make_shared<variable_vector_t>(values[0], vector_size);
        } else {
            new_vector = make_shared<variable_vector_t>(values);
        }
    } else {
        auto v = variable_vector_t(*variables->at(individual_name)[variable_name][timestep]);
        auto index = static_cast<valarray<size_t>>(to_valarray<size_t>(update["index"]) - 1UL);
        if (value_fill) {
            // For a fill update
            v[index] = values[0];
        } else {
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
    for(const auto& state_storage : states->at(individual_name)) {
        auto state_vector = vector<string>(population_sizes.at(individual_name));
        for (const auto& state : *state_storage) {
            for (const auto index : state.second) {
                state_vector[index - 1] = state.first;
            }
        }
        state_values.insert(state_values.end(), cbegin(state_vector), cend(state_vector));
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
        static_cast<int>(timesteps),
        static_cast<int>(num_variables)
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
