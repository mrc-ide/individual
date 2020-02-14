/*
 * SimulationFrameR.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_INTERFACE_SIMULATIONFRAMER_H_
#define SRC_INTERFACE_SIMULATIONFRAMER_H_

#include <Rcpp.h>

using namespace Rcpp;

class SimulationFrameR {
public:
	SimulationFrameR();
	NumericVector get_state(int individual_index, int state_index);
	NumericVector get_variable(int individual_index, int state_index);
};

#endif /* SRC_INTERFACE_SIMULATIONFRAMER_H_ */
