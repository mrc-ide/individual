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
#include <sstream>

struct CategoricalVariable : public Variable {
    named_array_t<individual_index_t> indices;

    size_t size;

    using update_t = std::pair<std::string, individual_index_t>;
    std::queue<update_t> updates;

    CategoricalVariable(
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

    virtual individual_index_t get_index_of(
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

    virtual individual_index_t get_index_of(
        const std::string category
    ) const {
        auto result = individual_index_t(size);
        if (indices.find(category) == indices.end()) {
            std::stringstream message;
            message << "unknown category: " << category;
            Rcpp::stop(message.str()); 
        }
        result |= indices.at(category);
        return result;
    }

    virtual int get_size_of(
        const std::vector<std::string> categories        
    ) const {
        int result{0};
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

    virtual int get_size_of(
        const std::string category        
    ) const {
        int result{0};
        if (indices.find(category) == indices.end()) {
            std::stringstream message;
            message << "unknown category: " << category;
            Rcpp::stop(message.str());
        } else {
            result += indices.at(category).size();
        }            
        return result;
    }

    virtual void queue_update(
        const std::string category,
        const individual_index_t& index
    ) {
        updates.push({ category, index });
    }

    virtual void update() override {
        while(updates.size() > 0) {
            auto& next = updates.front();
            auto inverse_update = ~next.second;
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
};

#endif /* INST_INCLUDE_CATEGORICAL_VARIABLE_H_ */
