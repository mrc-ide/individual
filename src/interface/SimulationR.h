/*
 * SimulationR.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_INTERFACE_SIMULATIONR_H_
#define SRC_INTERFACE_SIMULATIONR_H_

#include "SimulationFrameR.h"
#include <Rcpp.h>

using namespace Rcpp;

class SimulationR {

public:
	SimulationR();
	List render();
	SimulationFrameR get_current_frame();
	void apply_updates(List);
};

#endif /* SRC_INTERFACE_SIMULATIONR_H_ */
