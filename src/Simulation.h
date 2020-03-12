/*
 * Simulation.h
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#ifndef SRC_SIMULATION_H_
#define SRC_SIMULATION_H_

#include <Rcpp.h>
#include "SimulationFrame.h"
#include "types.h"

using namespace Rcpp;
using namespace std;

class Simulation {
    shared_ptr<states_t> states;
    shared_ptr<variables_t> variables;
    size_t current_timestep = 0;
    vector<string> individual_names;
    vector<string> state_names;
    named_array_t<vector<string>> variable_names;
    named_array_t<size_t> population_sizes;
    size_t timesteps;
    void apply_state_update(const Environment, const size_t);
    void apply_variable_update(const Environment, const size_t);
    NumericVector render_variables(const string name) const;
public:
    Simulation(const List, const int);
    void apply_updates(const List);
    SimulationFrame get_current_frame() const;
    DataFrame render(const Environment) const;
};

#endif /* SRC_SIMULATION_H_ */
