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

class CategoricalVariable;

//' @title a variable object for categorical variables
//' @description This class provides functionality for variables which takes values
//' in a discrete finite set. It inherits from Variable.
//' It contains the following data members:
//'     * indices: an unordered_map mapping strings to bitsets
//'     * size: size of the population
//'     * updates: a priority queue of pairs of values and indices to update
class CategoricalVariable : public Variable {
    
    const std::vector<std::string> categories;
    named_array_t<individual_index_t> indices;
    using update_t = std::pair<std::string, individual_index_t>;
    std::queue<update_t> updates;
    individual_index_t shrink_index;
    std::vector<std::string> extend_values;

public:
    CategoricalVariable(
        const std::vector<std::string>&,
        const std::vector<std::string>&
    );
    virtual ~CategoricalVariable() = default;

    virtual individual_index_t get_index_of(const std::vector<std::string>) const;
    virtual individual_index_t get_index_of(const std::string) const;

    virtual size_t get_size_of(const std::vector<std::string>) const;
    virtual size_t get_size_of(const std::string) const;

    virtual void queue_update(const std::string, const individual_index_t&);
    virtual void queue_extend(const std::vector<std::string>&);
    virtual void queue_shrink(const std::vector<size_t>&);
    virtual void queue_shrink(const individual_index_t&);
    virtual const std::vector<std::string>& get_categories() const;
    virtual void resize() override;
    virtual size_t size() const override;
    virtual void update() override;
};


inline CategoricalVariable::CategoricalVariable(
    const std::vector<std::string>& categories, 
    const std::vector<std::string>& values
) : categories(categories), shrink_index(individual_index_t(values.size())) {
    const auto size = values.size();
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
    auto result = individual_index_t(size());
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

//' @title queue new values to add to the variable
inline void CategoricalVariable::queue_extend(
    const std::vector<std::string>& new_values
) {
    extend_values.insert(
        extend_values.cend(),
        new_values.cbegin(),
        new_values.cend()
    );
}

//' @title queue values to be erased from the variable
inline void CategoricalVariable::queue_shrink(
    const individual_index_t& index
) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    shrink_index |= index;
}

//' @title queue values to be erased from the variable
inline void CategoricalVariable::queue_shrink(
    const std::vector<size_t>& index
) {
    for (const auto& x : index) {
        if (x >= size()) {
            Rcpp::stop("Invalid vector index for variable shrink");
        }
    }
    shrink_index.insert(index.cbegin(), index.cend());
}

inline void CategoricalVariable::resize() {
    auto size_changed = false;

    // Apply shrink updates
    if (shrink_index.size() > 0) {
        auto index = std::vector<size_t>(
            shrink_index.cbegin(),
            shrink_index.cend()
        );
        for (auto& entry : indices) {
            entry.second.shrink(index);
        }
        shrink_index.clear();
        size_changed = true;
    }

    // Apply extension updates
    if (extend_values.size() > 0) {
        auto shrunk_size = size();
        for (auto& entry : indices) {
            entry.second.extend(extend_values.size());
        }
        for (auto i = 0u; i < extend_values.size(); ++i) {
            indices.at(extend_values[i]).insert(shrunk_size + i);
        }
        extend_values.clear();
        size_changed = true;
    }

    if (size_changed) {
        shrink_index = individual_index_t(size());
    }
}

inline size_t CategoricalVariable::size() const {
    return indices.begin()->second.max_size();
}

inline const std::vector<std::string>& CategoricalVariable::get_categories() const {
    return categories;
}

#endif /* INST_INCLUDE_CATEGORICAL_VARIABLE_H_ */
