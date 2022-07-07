/*
 * variable.cpp
 *
 *  Created on: 1 Jul 2022
 *      Author: gc1610
 */


#include "../inst/include/Variable.h"
#include <Rcpp.h>

//[[Rcpp::export]]
size_t variable_get_size(Rcpp::XPtr<Variable> variable) {
    return variable->size();
}

//[[Rcpp::export]]
void variable_update(Rcpp::XPtr<Variable> variable) {
    variable->update();
}

//[[Rcpp::export]]
void variable_resize(Rcpp::XPtr<Variable> variable) {
    variable->resize();
}
