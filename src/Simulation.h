/*
 * Simulation.h
 *
 *  Created on: 3 Mar 2020
 *      Author: giovanni
 */

#ifndef SRC_SIMULATION_H_
#define SRC_SIMULATION_H_

#include <Rcpp.h>
#include "SimulationFrame.h"
#include "types.h"

using namespace Rcpp;
using namespace std;

class Simulation {
    shared_ptr<states_t> states;
    shared_ptr<variables_t> variables;
    unsigned int current_timestep = 0;
public:
    Simulation(const List, const int);
    void apply_updates(const List);
    SimulationFrame get_current_frame() const;
    List render() const;
};

#endif /* SRC_SIMULATION_H_ */
