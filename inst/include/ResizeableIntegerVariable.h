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
    individual_index_t get_index_of_set(const int value) const;
    size_t get_size_of_set(const std::vector<int>& values_set) const;
    size_t get_size_of_set(const int value) const;
    individual_index_t get_index_of_range(const int a, const int b) const;
    size_t get_size_of_range(const int a, const int b) const;
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

//' @title return bitset giving index of individuals whose value is equal to a specific scalar
inline individual_index_t ResizeableIntegerVariable::get_index_of_set(
    const int value
) const {
    auto result = individual_index_t(values.size());
    auto it = std::cbegin(values);
    for (auto i = 0u; i < values.size(); ++i) {
        if (value == *it) {
            result.insert(i);
        }
        ++it;
    }
    return result;
}

//' @title return number of individuals whose value is in a finite set
inline size_t ResizeableIntegerVariable::get_size_of_set(
    const std::vector<int>& values_set
) const {
    
    size_t result = std::count_if(values.begin(), values.end(), [&](const int v) -> bool {
        auto findit = std::find(values_set.begin(), values_set.end(), v);
        return findit != values_set.end();
    });
    
    return result;
}

//' @title return number of individuals whose value is equal to a specific scalar
inline size_t ResizeableIntegerVariable::get_size_of_set(
    const int value
) const {
    size_t result = std::count(values.begin(), values.end(), value);
    return result;
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
inline individual_index_t ResizeableIntegerVariable::get_index_of_range(
    const int a,
    const int b
) const {
    auto result = individual_index_t(values.size());
    auto it = std::cbegin(values);
    for (auto i = 0u; i < values.size(); ++i) {
        auto value = *it;
        if ( !(value < a) && !(b < value) ) {
            result.insert(i);
        }
        ++it;
    }
    return result;
}

//' @title return number of individuals whose value is in some range [a,b]
inline size_t ResizeableIntegerVariable::get_size_of_range(
    const int a,
    const int b
) const {
    size_t result = std::count_if(values.begin(), values.end(), [&](const int v) -> bool {
        return !(v < a) && !(b < v);
    });
    return result;
}

#endif /* INST_INCLUDE_RESIZEABLE_INTEGER_VARIABLE_H_ */
