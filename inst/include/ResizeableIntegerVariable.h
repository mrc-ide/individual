/*
 * ResizeableIntegerVariable.h
 *
 *  Created on: 09 Dec 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_RESIZEABLE_INTEGER_VARIABLE_H_
#define INST_INCLUDE_RESIZEABLE_INTEGER_VARIABLE_H_

#include "ResizeableNumericVariable.h"

struct ResizeableIntegerVariable : public ResizeableNumericVariable<int> {
    ResizeableIntegerVariable(const std::vector<int>& values) : ResizeableNumericVariable<int>(values) {};
    individual_index_t get_index_of_set(const std::vector<int>&) const;
};

inline individual_index_t ResizeableIntegerVariable::get_index_of_set(
    const std::vector<int>& values_set
) const {
    auto result = individual_index_t(values.size());
    auto it = std::cbegin(values);
    for (auto i = 0u; i < values.size(); ++i) {
        auto findit = std::find(values_set.begin(), values_set.end(), *it);
        if(findit != values_set.end()){
            result.insert(i);
        }
        ++it;
    }
    return result;
}

#endif /* INST_INCLUDE_RESIZEABLE_INTEGER_VARIABLE_H_ */
