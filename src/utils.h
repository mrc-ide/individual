/*
 * utils.h
 *
 *  Created on: 5 January 2020
 *      Author: gc1610
 */

#ifndef UTILS_H_
#define UTILS_H_

#include <vector>

inline void decrement(std::vector<size_t>& x) {
    for (auto i = 0u; i < x.size(); ++i) {
        --x[i];
    }
}

#endif /* UTILS_H_ */
