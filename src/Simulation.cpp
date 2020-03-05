/*
 * Simulation.cpp
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#include "Simulation.h"
#include "SimulationFrame.h"
#include "Log.h"

Simulation::Simulation(const List individuals, const int timesteps) :states(nullptr), variables(nullptr) {
    for (const Environment& individual : individuals) {

        Log(log_level::debug).get() << "pop size" << endl;
        // Get the population size
        List state_descriptors(individual["states"]);
        auto population_size = 0;
        for (Environment state : state_descriptors) {
            population_size += as<size_t>(state["initial_size"]);
        }

        Log(log_level::debug).get() << "initial state" << endl;
        // Initialise the initial state
        auto initial_state = make_shared<state_vector_t>(state_vector_t(population_size));
        auto start = 0;
        for (Environment state : state_descriptors) {
            auto size = as<size_t>(state["initial_size"]);
            if (size == 0) continue;
            (*initial_state)[slice(start, size, 1)] = valarray<string>(as<string>(state["name"]), size);
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
            auto& variable_timeline = (*variables)[as<string>(individual["name"])][as<string>(variable["name"])];
            variable_timeline = timeline_t<variable_vector_t>(timesteps, nullptr);
            Function initialiser(variable["initialiser"]);
            auto initial_values = as<vector<double>>(initialiser(population_size));
            variable_timeline[0] = make_shared<variable_vector_t>(variable_vector_t(&initial_values[0], population_size));
        }
    }

}

SimulationFrame Simulation::get_current_frame() const {
    return SimulationFrame(states, variables, current_timestep);
}

void Simulation::apply_updates(const List) {
}

List Simulation::render() const {
}
