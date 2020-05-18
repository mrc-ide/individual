/*
 * module.h
 *
 *  Created on: 15 May 2020
 *      Author: gc1610
 */

#ifndef MODULE_H_
#define MODULE_H_

#include <Rcpp.h>

std::vector<size_t> process_get_state(
    Rcpp::XPtr<ProcessAPI>,
    const std::string,
    const std::vector<std::string>
) __attribute__ ((noinline));

#endif /* MODULE_H_ */
