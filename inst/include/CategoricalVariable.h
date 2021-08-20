/*
 * CategoricalVariable.h
 *
 *  Created on: 15 Feb 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_CATEGORICAL_VARIABLE_H_
#define INST_INCLUDE_CATEGORICAL_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>

struct CategoricalVariable;


//' @title a variable object for categorical variables
//' @description This class provides functionality for variables which takes values
//' in a discrete finite set. It inherits from Variable.
//' It contains the following data members:
//'     * indices: an unordered_map mapping strings to bitsets
//'     * size: size of the populations
//'     * updates: a priority queue of pairs of values and indices to update
struct CategoricalVariable : public Variable {
    
    named_array_t<individual_index_t> indices;
    size_t size;
    using update_t = std::pair<std::string, individual_index_t>;
    std::queue<update_t> updates;

    CategoricalVariable(const std::vector<std::string> categories, const std::vector<std::string> values);
    virtual ~CategoricalVariable() = default;

    virtual individual_index_t get_index_of(const std::vector<std::string> categories) const;
    virtual individual_index_t get_index_of(const std::string category) const;

    virtual size_t get_size_of(const std::vector<std::string> categories) const;
    virtual size_t get_size_of(const std::string category) const;

    virtual void queue_update(const std::string category, const individual_index_t& index);
    virtual void update() override;
    
};


inline CategoricalVariable::CategoricalVariable(
    const std::vector<std::string> categories, 
    const std::vector<std::string> values
) : size(values.size())
{
    for (auto& category : categories) {
        indices.insert({ category, individual_index_t(size) });
    }
    for (auto i = 0u; i < size; ++i) {
        indices.at(values[i]).insert(i);
    }
}

//' @title return bitset giving index of individuals whose value is in a set of categories
inline individual_index_t CategoricalVariable::get_index_of(
        const std::vector<std::string> categories
) const {
    auto result = individual_index_t(size);
    for (auto& category : categories) {
        if (indices.find(category) == indices.end()) {
            std::stringstream message;
            message << "unknown category: " << category;
            Rcpp::stop(message.str());
        }
        result |= indices.at(category);
    }
    return result;
}

//' @title return bitset giving index of individuals whose value is equal to some category
inline individual_index_t CategoricalVariable::get_index_of(
        const std::string category
) const {
    if (indices.find(category) == indices.end()) {
        std::stringstream message;
        message << "unknown category: " << category;
        Rcpp::stop(message.str()); 
    }
    return individual_index_t(indices.at(category));
}

//' @title return number of individuals whose value is in a set of categories
inline size_t CategoricalVariable::get_size_of(
        const std::vector<std::string> categories        
) const {
    size_t result{0};
    for (const auto& category : categories) {
        if (indices.find(category) == indices.end()) {
            std::stringstream message;
            message << "unknown category: " << category;
            Rcpp::stop(message.str());
        } else {
            result += indices.at(category).size();
        }            
    }
    return result;
}

//' @title return number of individuals whose value is equal to some category
inline size_t CategoricalVariable::get_size_of(
        const std::string category        
) const {
    size_t result{0};
    if (indices.find(category) == indices.end()) {
        std::stringstream message;
        message << "unknown category: " << category;
        Rcpp::stop(message.str());
    } else {
        result += indices.at(category).size();
    }
    return result;
}

//' @title queue a state update for some subset of individuals
inline void CategoricalVariable::queue_update(
        const std::string category,
        const individual_index_t& index
) {
    updates.push({ category, index });
}

//' @title apply all queued state updates in FIFO order
inline void CategoricalVariable::update() {
    while(updates.size() > 0) {
        auto& next = updates.front();
        auto inverse_update = !next.second;
        for (auto& entry : indices) {
            if (entry.first == next.first) {
                // destination state
                entry.second |= next.second;
            } else {
                // other state
                entry.second &= inverse_update;
            }
        }
        updates.pop();
    }
}

#endif /* INST_INCLUDE_CATEGORICAL_VARIABLE_H_ */
