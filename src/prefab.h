/*
 * prefab.h
 *
 *  Created on: 13 May 2020
 *      Author: gc1610
 */

#ifndef PREFAB_H_
#define PREFAB_H_

#include "../inst/include/individual_types.h"

listener_t update_state(const std::string, const std::string);
listener_t reschedule(const std::string, double);
process_t fixed_probability_state_change(const std::string, const std::string, const std::string, double);

#endif /* PREFAB_H_ */
