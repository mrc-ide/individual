/*
 * SimulationFrame.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_SIMULATIONFRAME_H_
#define SRC_SIMULATIONFRAME_H_

#include <vector>

using namespace std;

class SimulationFrame {
public:
	SimulationFrame();
	virtual ~SimulationFrame();
	vector<unsigned int>get_state(int individual_index, int state_index);
	vector<double>get_variable(int individual_index, int state_index);
	SimulationFrame(const SimulationFrame &other);
	SimulationFrame& operator=(const SimulationFrame &other);
	SimulationFrame(SimulationFrame &&other);
	SimulationFrame& operator=(SimulationFrame &&other);
};

#endif /* SRC_SIMULATIONFRAME_H_ */
