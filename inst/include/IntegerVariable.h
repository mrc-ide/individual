/*
 * IntegerVariable.h
 *
 *  Created on: 16 Feb 2021
 *      Author: slwu89
 */

#ifndef INST_INCLUDE_INTEGER_VARIABLE_H_
#define INST_INCLUDE_INTEGER_VARIABLE_H_

#include "NumericVariable.h"

struct IntegerVariable;


//' @title a variable object for signed integers
//' @description This class provides functionality for variables which takes values
//' in the signed integers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * size: the number of elements stored (size of population)
//'     * values: a vector of values
struct IntegerVariable : public NumericVariable<int> {
    IntegerVariable(const std::vector<int>& values);
    virtual ~IntegerVariable() = default;
    virtual individual_index_t get_index_of_set(const std::vector<int>&) const;
    virtual individual_index_t get_index_of_set(const int) const;
    virtual individual_index_t get_index_of_range(const int, const int) const;
    
    virtual size_t get_size_of_set(const std::vector<int>&) const;
    virtual size_t get_size_of_set(const int) const;
    virtual size_t get_size_of_range(const int, const int) const;
};

inline IntegerVariable::IntegerVariable(const std::vector<int>& values)
    : NumericVariable<int>(values) {}

//' @title return bitset giving index of individuals whose value is in a finite set
inline individual_index_t IntegerVariable::get_index_of_set(
    const std::vector<int>& values_set
) const {
    
    auto result = individual_index_t(size());
    for (auto i = 0u; i < size(); ++i) {
        auto findit = std::find(values_set.begin(), values_set.end(), values[i]);
        if(findit != values_set.end()){
            result.insert(i);
        }
    }
    
    return result;
}

//' @title return bitset giving index of individuals whose value is equal to a specific scalar
inline individual_index_t IntegerVariable::get_index_of_set(
    const int value
) const {
    
    auto result = individual_index_t(size());
    for (auto i = 0u; i < values.size(); ++i) {
        if ( values[i] == value ) {
            result.insert(i);
        }
    }
    
    return result;
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
inline individual_index_t IntegerVariable::get_index_of_range(
        const int a, const int b
) const {
    
    auto result = individual_index_t(size());
    for (auto i = 0u; i < values.size(); ++i) {
        if ( !(values[i] < a) && !(b < values[i]) ) {
            result.insert(i);
        }
    }
    
    return result;
}

//' @title return number of individuals whose value is in a finite set
inline size_t IntegerVariable::get_size_of_set(
        const std::vector<int>& values_set
) const {
    
    size_t result = std::count_if(values.begin(), values.end(), [&](const int v) -> bool {
        auto findit = std::find(values_set.begin(), values_set.end(), v);
        return findit != values_set.end();
    });
    
    return result;
}

//' @title return number of individuals whose value is equal to a specific scalar
inline size_t IntegerVariable::get_size_of_set(
        const int value
) const {
    
    size_t result = std::count(values.begin(), values.end(), value);
    return result;
}

//' @title return number of individuals whose value is in some range [a,b]
inline size_t IntegerVariable::get_size_of_range(
        const int a, const int b
) const {
    size_t result = std::count_if(values.begin(), values.end(), [&](const int v) -> bool {
        return !(v < a) && !(b < v);
    });
    
    return result;
}

#endif /* INST_INCLUDE_INTEGER_VARIABLE_H_ */
