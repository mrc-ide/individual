/*
 * DoubleVariable.h
 *
 *  Created on: 15 Feb 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_DOUBLE_VARIABLE_H_
#define INST_INCLUDE_DOUBLE_VARIABLE_H_

#include "Variable.h"
#include "vector_updates.h"
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
class DoubleVariable : public Variable {

    using update_t = std::pair<std::vector<double>, std::vector<size_t>>;
    std::queue<update_t> updates;
    std::queue<std::function<void (std::vector<double>&)>> resize_updates;
    std::vector<double> values;
    
public:
    DoubleVariable(const std::vector<double>& values);
    virtual ~DoubleVariable() = default;

    virtual std::vector<double> get_values() const;
    virtual std::vector<double> get_values(const individual_index_t& index) const;
    virtual std::vector<double> get_values(const std::vector<size_t>& index) const;

    virtual individual_index_t get_index_of_range(const double a, const double b) const;
    virtual size_t get_size_of_range(const double a, const double b) const;

    virtual void queue_update(const std::vector<double>& values, const std::vector<size_t>& index);
    virtual void queue_extend(const std::vector<double>&);
    virtual void queue_shrink(const std::vector<size_t>&);
    virtual void queue_shrink(const individual_index_t&);
    virtual void apply_resize_updates();
    virtual size_t size() const;

    virtual void update() override;
    
};


inline DoubleVariable::DoubleVariable(const std::vector<double>& values)
    : values(values)
{}

//' @title get all values
inline std::vector<double> DoubleVariable::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
inline std::vector<double> DoubleVariable::get_values(const individual_index_t& index) const {
    if (size() != index.max_size()) {
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
        if (index[i] >= size()) {
            std::stringstream message;
            message << "index for DoubleVariable out of range, supplied index: ";
            message << index[i] << ", size of variable: " << size();
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
    
    auto result = individual_index_t(size());
    for (auto i = 0u; i < size(); ++i) {
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
    if (values.empty()) {
        return;
    }
    if (values.size() > 1 && values.size() < size() && values.size() != index.size()) {
        Rcpp::stop("Mismatch between value and index length");
    }
    
    for (auto i : index) {
        if (i >= size()) {
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
    apply_resize_updates();
}

//' @title queue new values to add to the variable
inline void DoubleVariable::queue_extend(
    const std::vector<double>& new_values
) {
    auto update = VectorExtendUpdate<double>(new_values);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
inline void DoubleVariable::queue_shrink(
    const individual_index_t& index
) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    auto update = VectorShrinkUpdate<double>(index);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
inline void DoubleVariable::queue_shrink(
    const std::vector<size_t>& index
) {
    for (const auto& x : index) {
        if (x >= size()) {
            Rcpp::stop("Invalid vector index for variable shrink");
        }
    }
    auto update = VectorShrinkUpdate<double>(index);
    resize_updates.push([=](auto& values) { update.update(values); });
}

inline void DoubleVariable::apply_resize_updates() {
    while(resize_updates.size() > 0) {
        const auto& update = resize_updates.front();
        update(values);
        resize_updates.pop();
    }
}

inline size_t DoubleVariable::size() const {
    return values.size();
}

#endif /* INST_INCLUDE_DOUBLE_VARIABLE_H_ */
