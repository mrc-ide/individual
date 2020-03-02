/*
 * interface.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include <Rcpp.h>
#include "interface.h"

using namespace Rcpp;

RCPP_MODULE(individual_cpp) {
    class_<SimulationFrame>("SimFrameCpp")
		        .constructor<List, List, List, List>();
    //.method('get_state', &SimulationFrame::get_state)
    //.method('get_variable', &SimulationFrame::get_variable);
}
