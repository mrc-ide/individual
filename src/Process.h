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
    Rcpp::XPtr state;
    Rcpp::Environment scheduler;
    params_t params;
public:
    ProcessAPI(Rcpp::XPtr, Rcpp::Environment, Rcpp::List);
    const individual_index_t& get_state(const std::string, const std::vector<std::string>) const;
    const variable_vector_t& get_variable(const std::string, const std::string) const;
    void schedule(const std::string, const individual_index_t&, double);
    individual_index_t get_scheduled(const std::string) const;
    void clear_schedule(const std::string, const individual_index_t&);
    size_t get_timestep() const;
    const params_t& get_parameters() const;
    void create_state_update(
        const std::string,
        const std::string,
        const individual_index_t&
    );
    void create_variable_update(
        const std::string,
        const std::string,
        const individual_index_t&,
        const variable_vector_t&
    );
};

class Process {
   virtual void run(ProcessAPI&)=0;
};

#endif /* PROCESS_H_ */
