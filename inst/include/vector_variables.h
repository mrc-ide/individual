/*
 * vector_variables.h
 *
 *  Created on: 21 Jul 2022
 *      Author: gc1610
 *
 *  Template functions to be used with vector-based variables
 */

#ifndef VECTOR_VARIABLES_H_
#define VECTOR_VARIABLES_H_

#include "common_types.h"
#include <queue>

//' @title Apply state updates to a vector-based variable
//' @param updates queue of value/index pairs to apply in FIFO order
//' @param values variable values to update
template<class A>
inline void vector_update(
    std::queue<std::pair<std::vector<A>, std::vector<size_t>>>& updates,
    std::vector<A>& values
    ) {
    while(updates.size() > 0) {
        const auto& update = updates.front();
        const auto& new_values = update.first;
        const auto& index = update.second;
        
        auto vector_replacement = (index.size() == 0);
        auto value_fill = (new_values.size() == 1);
        
        if (vector_replacement) {
            // For a full vector replacement
            if (value_fill) {
                std::fill(values.begin(), values.end(), new_values[0]);
            } else {
                values = new_values;
            }
        } else {
            if (value_fill) {
                // For a fill update
                for (auto i : index) {
                    values[i] = new_values[0];
                }
            } else {
                // Subset assignment
                for (auto i = 0u; i < index.size(); ++i) {
                    values[index[i]] = new_values[i];
                }
            }
        }
        updates.pop();
    }
}

//' @title Resize a vector-based variable
//' @description performs shrinking and extending operations on a variable's
//value vector.
//' @param values a vector-based variable's value vector
//' @param shrink_index index of indices to remove
//' @param extend_values values to append to the values vector
template<class A>
inline void resize_vector(
    std::vector<A>& values, 
    individual_index_t& shrink_index,
    std::vector<A>& extend_values
) {
    auto size_changed = false;

    // Apply shrink updates
    if (shrink_index.size() > 0) {
        const auto index = std::vector<size_t>(
            shrink_index.cbegin(),
            shrink_index.cend()
        );
        auto new_values = std::vector<A>();
        new_values.reserve(values.size() - index.size());
        auto it = index.cbegin();
        for (auto i = 0u; i < values.size(); ++i) {
            if (it != index.cend() && i == *it) {
                ++it;
            } else {
                new_values.push_back(values[i]);
            }
        }
        values = new_values;
        shrink_index.clear();
        size_changed = true;
    }

    // Apply extension updates
    if (extend_values.size() > 0) {
        values.insert(
            values.cend(), 
            extend_values.cbegin(),
            extend_values.cend()
        );
        extend_values.clear();
    }

    if (size_changed) {
        shrink_index = individual_index_t(values.size());
    }
}

#endif /* VECTOR_VARIABLES_H_ */
