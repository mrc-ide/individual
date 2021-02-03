/*
 * state.cpp -> variable.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#include "../inst/include/common_types.h"
#include <Rcpp.h>

//[[Rcpp::export]]
void execute_process(Rcpp::XPtr<process_t> process, size_t timestep) {
    (*process)(timestep);
}
