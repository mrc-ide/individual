/*
 * module.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>

#include "Simulation.h"
#include "StateAPI.h"

RCPP_EXPOSED_CLASS(StateAPI)
RCPP_EXPOSED_CLASS(StateCppAPI)

RCPP_MODULE(individual_cpp) {
    Rcpp::class_<StateAPI>("SimAPICpp")
        .method("get_state", &StateAPI::get_state, "Get the state for a set of individuals")
        .method("get_variable", &StateAPI::get_variable, "Get a variable for a set of individuals")
    ;
    Rcpp::class_<Simulation>("SimulationCpp")
        .constructor<const Rcpp::List, const int>()
        .method("apply_updates", &Simulation::apply_updates, "Apply updates to the simulation")
        .method("get_state_api", &Simulation::get_state_api, "Return the simulation API")
        .method("get_state_cpp_api", &Simulation::get_state_cpp_api, "Return the simulation API")
        .method("tick", &Simulation::tick, "Increment the current timestep")
    ;
}
