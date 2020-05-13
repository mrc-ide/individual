/*
 * Process.h
 *
 *  Created on: 6 May 2020
 *      Author: gc1610
 */

#ifndef PROCESS_H_
#define PROCESS_H_

#include <Rcpp.h>
#include "State.h"
#include "types.h"

class ProcessAPI {
private:
    Rcpp::XPtr<State> state;
    Rcpp::Environment scheduler;
    params_t params;
public:
    ProcessAPI(Rcpp::XPtr<State>, Rcpp::Environment, Rcpp::List);
    const individual_index_t get_state(const std::string, const std::vector<std::string>) const;
    const variable_vector_t& get_variable(const std::string, const std::string) const;
    void schedule(const std::string, const individual_index_t&, double);
    individual_index_t get_scheduled(const std::string) const;
    void clear_schedule(const std::string, const individual_index_t&);
    size_t get_timestep() const;
    const params_t& get_parameters() const;
    void queue_state_update(
        const std::string,
        const std::string,
        const individual_index_t&
    );
    void queue_variable_update(
        const std::string,
        const std::string,
        const std::vector<size_t>&,
        const variable_vector_t&
    );
};

using listener_t = std::function<void (ProcessAPI&, individual_index_t&)>;
using process_t = std::function<void (ProcessAPI&)>;

#endif /* PROCESS_H_ */
