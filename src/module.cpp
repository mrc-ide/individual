/*
 * module.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>

#include "Simulation.h"
#include "SimulationAPI.h"

RCPP_EXPOSED_CLASS(SimulationAPI)

RCPP_MODULE(individual_cpp) {
    Rcpp::class_<SimulationAPI>("SimAPICpp")
        .method("get_state", &SimulationAPI::get_state, "Get the state for a set of individuals")
        .method("get_variable", &SimulationAPI::get_variable, "Get a variable for a set of individuals")
    ;
    Rcpp::class_<Simulation>("SimulationCpp")
        .constructor<const Rcpp::List, const int>()
        .method("apply_updates", &Simulation::apply_updates, "Apply updates to the simulation")
        .method("get_api", &Simulation::get_api, "Return the simulation API")
        .method("tick", &Simulation::tick, "Increment the current timestep")
    ;
}
