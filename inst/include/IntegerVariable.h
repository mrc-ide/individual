/*
 * IntegerVariable.h
 *
 *  Created on: 16 Feb 2021
 *      Author: slwu89
 */

#ifndef INST_INCLUDE_INTEGER_VARIABLE_H_
#define INST_INCLUDE_INTEGER_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>

struct IntegerVariable;


//' @title a variable object for signed integers
//' @description This class provides functionality for variables which takes values
//' in the signed integers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * size: the number of elements stored (size of population)
//'     * values: a vector of values
struct IntegerVariable : public Variable {

    using update_t = std::pair<std::vector<int>, std::vector<size_t>>;
    std::queue<update_t> updates;
    size_t size;
    std::vector<int> values;

    IntegerVariable(const std::vector<int>& values);
    virtual ~IntegerVariable() = default;

    virtual std::vector<int> get_values() const;
    virtual std::vector<int> get_values(const individual_index_t& index) const;
    virtual std::vector<int> get_values(const std::vector<size_t>& index) const;

    virtual individual_index_t get_index_of_set(const std::vector<int>& values_set) const;
    virtual individual_index_t get_index_of_set(const int value) const;
    virtual individual_index_t get_index_of_range(const int a, const int b) const;
    
    virtual size_t get_size_of_set_vector(const std::vector<int>& values_set) const;
    virtual size_t get_size_of_set_scalar(const int value) const;
    virtual size_t get_size_of_range(const int a, const int b) const;

    virtual void queue_update(const std::vector<int>& values, const std::vector<size_t>& index);
    virtual void update() override;

};


inline IntegerVariable::IntegerVariable(const std::vector<int>& values)
    : size(values.size()), values(values)
{}

//' @title get all values
inline std::vector<int> IntegerVariable::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
inline std::vector<int> IntegerVariable::get_values(const individual_index_t& index) const {
    if (size != index.max_size()) {
        Rcpp::stop("incompatible size bitset used to get values from IntegerVariable");
    }
    auto result = std::vector<int>(index.size());
    auto result_i = 0u;
    for (auto i : index) {
        result[result_i] = values[i];
        ++result_i;
    }
    return result;
}

//' @title get values at index given by a vector
inline std::vector<int> IntegerVariable::get_values(const std::vector<size_t>& index) const {
    
    auto result = std::vector<int>(index.size());
    for (auto i = 0u; i < index.size(); ++i) {
        if (index[i] >= size) {
            std::stringstream message;
            message << "index for IntegerVariable out of range, supplied index: " << index[i] << ", size of variable: " << size;
            Rcpp::stop(message.str()); 
        }
        result[i] = values[index[i]];
    }
    return result;
}

//' @title return bitset giving index of individuals whose value is in a finite set
inline individual_index_t IntegerVariable::get_index_of_set(
    const std::vector<int>& values_set
) const {
    
    auto result = individual_index_t(size);
    for (auto i = 0u; i < values.size(); ++i) {
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
    
    auto result = individual_index_t(size);
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
    
    auto result = individual_index_t(size);
    for (auto i = 0u; i < values.size(); ++i) {
        if ( !(values[i] < a) && !(b < values[i]) ) {
            result.insert(i);
        }
    }
    
    return result;
}

//' @title return number of individuals whose value is in a finite set
inline size_t IntegerVariable::get_size_of_set_vector(
        const std::vector<int>& values_set
) const {
    
    size_t result = std::count_if(values.begin(), values.end(), [&](const int v) -> bool {
        auto findit = std::find(values_set.begin(), values_set.end(), v);
        return findit != values_set.end();
    });
    
    return result;
}

//' @title return number of individuals whose value is equal to a specific scalar
inline size_t IntegerVariable::get_size_of_set_scalar(
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

//' @title queue a state update for some subset of individuals
inline void IntegerVariable::queue_update(
        const std::vector<int>& values,
        const std::vector<size_t>& index
) {
    if (values.size() > 1 && values.size() < size && values.size() != index.size()) {
        Rcpp::stop("Mismatch between value and index length");
    }
    for (auto i : index) {
        if (i >= size) {
            Rcpp::stop("Index out of bounds");
        }
    }
    updates.push({ values, index });
}

//' @title apply all queued state updates in FIFO order
inline void IntegerVariable::update() {
    while(updates.size() > 0) {
        const auto& update = updates.front();
        const auto& values = update.first;
        const auto& index = update.second;
        if (values.size() == 0) {
            return;
        }
        
        auto vector_replacement = (index.size() == 0);
        auto value_fill = (values.size() == 1);
        
        auto& to_update = this->values;
        
        if (vector_replacement) {
            // For a full vector replacement
            if (value_fill) {
                std::fill(to_update.begin(), to_update.end(), values[0]);
            } else {
                to_update = values;
            }
        } else {
            if (value_fill) {
                // For a fill update
                for (auto i : index) {
                    to_update[i] = values[0];
                }
            } else {
                // Subset assignment
                for (auto i = 0u; i < index.size(); ++i) {
                    to_update[index[i]] = values[i];
                }
            }
        }
        updates.pop();
    }
}

#endif /* INST_INCLUDE_INTEGER_VARIABLE_H_ */
