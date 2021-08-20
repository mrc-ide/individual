/*
 * DoubleVariable.h
 *
 *  Created on: 15 Feb 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_DOUBLE_VARIABLE_H_
#define INST_INCLUDE_DOUBLE_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>

struct DoubleVariable;


//' @title a variable object for double precision floats
//' @description This class provides functionality for variables which takes values
//' in the real numbers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * size: the number of elements stored (size of population)
//'     * values: a vector of values
struct DoubleVariable : public Variable {

    using update_t = std::pair<std::vector<double>, std::vector<size_t>>;
    std::queue<update_t> updates;
    size_t size;
    std::vector<double> values;
    
    DoubleVariable(const std::vector<double>& values);
    virtual ~DoubleVariable() = default;

    virtual std::vector<double> get_values() const;
    virtual std::vector<double> get_values(const individual_index_t& index) const;
    virtual std::vector<double> get_values(const std::vector<size_t>& index) const;

    virtual individual_index_t get_index_of_range(const double a, const double b) const;
    virtual size_t get_size_of_range(const double a, const double b) const;

    virtual void queue_update(const std::vector<double>& values, const std::vector<size_t>& index);
    virtual void update() override;
    
};


inline DoubleVariable::DoubleVariable(const std::vector<double>& values)
    : size(values.size()), values(values)
{}

//' @title get all values
inline std::vector<double> DoubleVariable::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
inline std::vector<double> DoubleVariable::get_values(const individual_index_t& index) const {
    if (size != index.max_size()) {
        Rcpp::stop("incompatible size bitset used to get values from DoubleVariable");
    }
    auto result = std::vector<double>(index.size());
    auto result_i = 0u;
    for (auto i : index) {
        result[result_i] = values[i];
        ++result_i;
    }
    return result;
}

//' @title get values at index given by a vector
inline std::vector<double> DoubleVariable::get_values(const std::vector<size_t>& index) const {
    
    auto result = std::vector<double>(index.size());
    for (auto i = 0u; i < index.size(); ++i) {
        if (index[i] >= size) {
            std::stringstream message;
            message << "index for DoubleVariable out of range, supplied index: " << index[i] << ", size of variable: " << size;
            Rcpp::stop(message.str()); 
        }
        result[i] = values[index[i]];
    }
    return result;
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
inline individual_index_t DoubleVariable::get_index_of_range(
        const double a, const double b
) const {
    
    auto result = individual_index_t(size);
    for (auto i = 0u; i < values.size(); ++i) {
        if( !(values[i] < a) && !(b < values[i]) ) {
            result.insert(i);
        }
    }
    
    return result;
    
}

//' @title return number of individuals whose value is in some range [a,b]
inline size_t DoubleVariable::get_size_of_range(
        const double a, const double b
) const {
    
    size_t result = std::count_if(values.begin(), values.end(), [&](const double v) -> bool {
        return !(v < a) && !(b < v);
    });
    
    return result;
    
}

//' @title queue a state update for some subset of individuals
inline void DoubleVariable::queue_update(
        const std::vector<double>& values,
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
inline void DoubleVariable::update() {
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

#endif /* INST_INCLUDE_DOUBLE_VARIABLE_H_ */
