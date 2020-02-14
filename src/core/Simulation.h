/*
 * Simulation.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_SIMULATION_H_
#define SRC_SIMULATION_H_

#include "SimulationOutput.h"
#include "SimulationFrame.h"
#include "Update.h"
#include <memory>
#include <vector>

using namespace std;

class Simulation {
public:
	Simulation();
	shared_ptr<SimulationOutput> render();
	shared_ptr<SimulationFrame> get_current_frame();
	void apply_updates(vector<Update>);
	Simulation(const Simulation &other) = delete;
	Simulation(Simulation &&other) = delete;
	Simulation& operator=(const Simulation &other) = delete;
	Simulation& operator=(Simulation &&other) = delete;
};

#endif /* SRC_SIMULATION_H_ */
