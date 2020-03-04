/*
 * interface.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>

#include "SimulationFrame.h"
#include "Simulation.h"

using namespace Rcpp;

RCPP_MODULE(individual_cpp) {
    class_<SimulationFrame>("SimFrameCpp")
        .method("get_state", &SimulationFrame::get_state, "Get the state for a set of individuals")
        .method("get_variable", &SimulationFrame::get_variable, "Get a variable for a set of individuals")
    ;
    class_<Simulation>("SimulationCpp")
        .constructor<const List, const int>()
        .method("apply_updates", &Simulation::apply_updates, "Apply updates to the simulation")
        .method("render", &Simulation::render, "Return the complete simulation")
        .method("get_current_frame", &Simulation::get_current_frame, "Return the current SimulationFrame")
    ;
}
