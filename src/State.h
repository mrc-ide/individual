/*
 * Simulation.h
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#ifndef SRC_STATE_H_
#define SRC_STATE_H_

#include <Rcpp.h>
#include "types.h"

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
    State(const Rcpp::List);
    void apply_updates();
    individual_index_t& get_state(std::string, std::vector<std::string>) const;
    variable_vector_t& get_variable(std::string, std::string) const;
    void queue_state_update(const std::string, const std::string, const individual_index_t&);
    void queue_variable_update(const std::string, const std::string, const individual_index_t&, const variable_vector_t&);
};

#endif
