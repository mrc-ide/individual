/*
 * Process.h
 *
 *  Created on: 6 May 2020
 *      Author: gc1610
 */

#ifndef PROCESS_H_
#define PROCESS_H_

#include "StateCppAPI.h"
#include <Rcpp.h>

class ProcessAPI {
private:
    StateCppAPI state;
    Rcpp::Environment rapi;
    params_t params;
public:
    ProcessAPI(StateCppAPI, Rcpp::Environment);
    const individual_index_t& get_state(std::string, std::vector<std::string>) const;
    const variable_vector_t& get_variable(std::string, std::string) const;
    void schedule(std::string, individual_index_t&, double);
    individual_index_t get_scheduled(std::string) const;
    void clear_schedule(std::string, individual_index_t&);
    size_t get_timestep() const;
    const params_t& get_parameters() const;
};

class Process {
   virtual void run(ProcessAPI&)=0;
};

#endif /* PROCESS_H_ */
