/*
 * common_types.h
 *
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_COMMON_TYPES_H_
#define INST_INCLUDE_COMMON_TYPES_H_

#include <vector>
#include <unordered_map>
#include <string>
#include <functional>
#include "IterableBitset.h"

template<class T>
using named_array_t = std::unordered_map<std::string, T>;

using individual_index_t = IterableBitset<uint64_t>;

using process_t = std::function<void (size_t)>;

#endif /* INST_INCLUDE_COMMON_TYPES_H_ */
