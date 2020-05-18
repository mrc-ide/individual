/*
 * individual_types.h
 *
 *  Created on: 12 May 2020
 *      Author: gc1610
 */

#ifndef INDIVIDUAL_TYPES_H_
#define INDIVIDUAL_TYPES_H_

#include <Rcpp.h>
#include "State.h"
#include "Process.h"

using listener_t = std::function<void (ProcessAPI&, individual_index_t&)>;
using process_t = std::function<void (ProcessAPI&)>;

#endif /* INDIVIDUAL_TYPES_H_ */
