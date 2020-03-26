/*
 * SimulationFrame.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_INTERFACE_R_INTERFACE_H_
#define SRC_INTERFACE_R_INTERFACE_H_

#include <Rcpp.h>
#include "types.h"

class SimulationFrame {
    std::shared_ptr<const states_t> states;
    std::shared_ptr<const variables_t> variables;
public:
    SimulationFrame(std::shared_ptr<const states_t>,std::shared_ptr<const variables_t>);
    std::vector<size_t> get_state(Rcpp::Environment, Rcpp::List) const;
    std::vector<double> get_variable(Rcpp::Environment, Rcpp::Environment) const;
};


#endif /* SRC_INTERFACE_R_INTERFACE_H_ */
