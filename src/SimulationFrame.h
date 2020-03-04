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

class SimulationFrame;
RCPP_EXPOSED_CLASS(SimulationFrame);

class SimulationFrame {
    shared_ptr<const states_t> states;
    shared_ptr<const variables_t> variables;
    const unsigned int current_timestep;
public:
    SimulationFrame(
        shared_ptr<const states_t>,
        shared_ptr<const variables_t>,
        const unsigned int
    );
    vector<unsigned int> get_state(string, vector<string>) const;
    NumericVector get_variable(string, string) const;
};


#endif /* SRC_INTERFACE_R_INTERFACE_H_ */
