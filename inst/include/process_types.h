/*
 * process_types.h
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_PROCESS_TYPES_H_
#define INST_INCLUDE_PROCESS_TYPES_H_

#include "State.h"

class ProcessAPI;

using listener_t = std::function<void (ProcessAPI&, individual_index_t&)>;
using process_t = std::function<void (ProcessAPI&)>;

#endif /* INST_INCLUDE_PROCESS_TYPES_H_ */
