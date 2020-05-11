/*
 * SimulationFrame.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_STATE_API_H_
#define SRC_STATE_API_H_

#include <Rcpp.h>
#include "StateCppAPI.h"
#include "types.h"

class StateAPI {
    StateCppAPI impl;
public:
    StateAPI(StateCppAPI impl);
    std::vector<size_t> get_state(Rcpp::Environment, Rcpp::List) const;
    std::vector<double> get_variable(Rcpp::Environment, Rcpp::Environment) const;
};


#endif
