/*
 * utils.h
 *
 *  Created on: 5 January 2020
 *      Author: gc1610
 */

#ifndef SRC_UTILS_H_
#define SRC_UTILS_H_

template<class A>
inline void decrement(A& x) {
    for (auto& i : x)
        --i;
}

#endif /* SRC_UTILS_H_ */
