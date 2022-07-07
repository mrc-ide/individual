/*
 * NumericVariable.h
 *
 *  Created on: 30 Jun 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_NUMERIC_VARIABLE_H_
#define INST_INCLUDE_NUMERIC_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>

template <class A>
class NumericVariable;

//' @title a variable object for scalar numbers
//' @description This class provides functionality for variables which takes values
//' in the real numbers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * size: the number of elements stored (size of population)
//'     * values: a vector of values
template <class A>
class NumericVariable : public Variable {

    using update_t = std::pair<std::vector<A>, std::vector<size_t>>;
    std::queue<update_t> updates;
    individual_index_t shrink_index;
    std::vector<A> extend_values;

protected:
    std::vector<A> values;
    
public:
    NumericVariable(const std::vector<A>& values);
    virtual ~NumericVariable() = default;

    virtual std::vector<A> get_values() const;
    virtual std::vector<A> get_values(const individual_index_t& index) const;
    virtual std::vector<A> get_values(const std::vector<size_t>& index) const;

    virtual individual_index_t get_index_of_range(const A a, const A b) const;
    virtual size_t get_size_of_range(const A a, const A b) const;

    virtual void queue_update(const std::vector<A>& values, const std::vector<size_t>& index);
    virtual void queue_extend(const std::vector<A>&);
    virtual void queue_shrink(const std::vector<size_t>&);
    virtual void queue_shrink(const individual_index_t&);
    virtual void resize() override;
    virtual size_t size() const override;

    virtual void update() override;
};

template<class A>
inline NumericVariable<A>::NumericVariable(const std::vector<A>& values)
    : shrink_index(individual_index_t(values.size())), values(values) 
{}

//' @title get all values
template<class A>
inline std::vector<A> NumericVariable<A>::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
template<class A>
inline std::vector<A> NumericVariable<A>::get_values(const individual_index_t& index) const {
    if (size() != index.max_size()) {
        Rcpp::stop("incompatible size bitset used to get values from NumericVariable<A>");
    }
    auto result = std::vector<A>(index.size());
    auto result_i = 0u;
    for (auto i : index) {
        result[result_i] = values[i];
        ++result_i;
    }
    return result;
}

//' @title get values at index given by a vector
template<class A>
inline std::vector<A> NumericVariable<A>::get_values(const std::vector<size_t>& index) const {
    
    auto result = std::vector<A>(index.size());
    for (auto i = 0u; i < index.size(); ++i) {
        if (index[i] >= size()) {
            std::stringstream message;
            message << "index for NumericVariable out of range, supplied index: ";
            message << index[i] << ", size of variable: " << size();
            Rcpp::stop(message.str()); 
        }
        result[i] = values[index[i]];
    }
    return result;
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
template<class A>
inline individual_index_t NumericVariable<A>::get_index_of_range(
        const A a, const A b
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
template<class A>
inline size_t NumericVariable<A>::get_size_of_range(
        const A a, const A b
) const {
    
    size_t result = std::count_if(values.begin(), values.end(), [&](const A v) -> bool {
        return !(v < a) && !(b < v);
    });
    
    return result;
    
}

//' @title queue a state update for some subset of individuals
template<class A>
inline void NumericVariable<A>::queue_update(
        const std::vector<A>& values,
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
template<class A>
inline void NumericVariable<A>::update() {
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
}

//' @title queue new values to add to the variable
template<class A>
inline void NumericVariable<A>::queue_extend(
    const std::vector<A>& new_values
) {
    extend_values.insert(
        extend_values.cend(),
        new_values.cbegin(),
        new_values.cend()
    );
}

//' @title queue values to be erased from the variable
template<class A>
inline void NumericVariable<A>::queue_shrink(
    const individual_index_t& index
) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    shrink_index |= index;
}

//' @title queue values to be erased from the variable
template<class A>
inline void NumericVariable<A>::queue_shrink(
    const std::vector<size_t>& index
) {
    for (const auto& x : index) {
        if (x >= size()) {
            Rcpp::stop("Invalid vector index for variable shrink");
        }
    }
    shrink_index.insert(index.cbegin(), index.cend());
}

template<class A>
inline void NumericVariable<A>::resize() {
    auto size_changed = false;

    // Apply shrink updates
    if (shrink_index.size() > 0) {
        auto index = std::vector<size_t>(
            shrink_index.cbegin(),
            shrink_index.cend()
        );
        auto new_values = std::vector<A>();
        new_values.reserve(values.size() - index.size());
        auto it = index.cbegin();
        for (auto i = 0u; i < values.size(); ++i) {
            if (i == *it) {
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
        shrink_index = individual_index_t(size());
    }
}

template<class A>
inline size_t NumericVariable<A>::size() const {
    return values.size();
}

#endif /* INST_INCLUDE_NUMERIC_VARIABLE_H_ */
