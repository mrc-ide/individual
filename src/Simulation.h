/*
 * Simulation.h
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#ifndef SRC_SIMULATION_H_
#define SRC_SIMULATION_H_

#include <Rcpp.h>

#include "StateAPI.h"
#include "StateCppAPI.h"
#include "types.h"

class Simulation {
    std::shared_ptr<states_t> states;
    std::shared_ptr<variables_t> variables;
    size_t current_timestep = 0;
    std::vector<std::string> individual_names;
    named_array_t<std::vector<std::string>> variable_names;
    named_array_t<size_t> population_sizes;
    size_t timesteps;
    void apply_state_update(const Rcpp::Environment, states_t&);
    void apply_variable_update(const Rcpp::Environment, variables_t&);
public:
    Simulation(const Rcpp::List, const int);
    void apply_updates(const Rcpp::List);
    void tick();
    StateAPI get_state_api() const;
    StateCppAPI get_state_cpp_api() const;
};

#endif /* SRC_SIMULATION_H_ */
