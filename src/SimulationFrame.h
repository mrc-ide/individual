/*
 * SimulationFrameR.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_INTERFACE_R_INTERFACE_H_
#define SRC_INTERFACE_R_INTERFACE_H_

#include <Rcpp.h>
#include "types.h"

using namespace Rcpp;
using namespace std;

class SimulationFrame {
    shared_ptr<const states_t> states;
    shared_ptr<const variables_t> variables;
public:
    SimulationFrame(shared_ptr<const states_t>,shared_ptr<const variables_t>);
    vector<size_t> get_state(Environment, List) const;
    vector<double> get_variable(Environment, Environment) const;
};


#endif /* SRC_INTERFACE_R_INTERFACE_H_ */
