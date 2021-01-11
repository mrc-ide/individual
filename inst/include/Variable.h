/*
 * state.h -> Variable.h
 *
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_STATE_H_
#define INST_INCLUDE_STATE_H_

#include <tuple>
#include <queue>
#include <sstream>
#include <Rcpp.h>
#include "common_types.h"

struct Variable {
    virtual void update() = 0;
};

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

    individual_index_t get_index_of(
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

    void queue_update(
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

struct DoubleVariable : public Variable {

    using update_t = std::pair<std::vector<double>, std::vector<size_t>>;
    std::queue<update_t> updates;
    size_t size;
    std::vector<double> values;

    DoubleVariable(const std::vector<double>& values)
        : values(values), size(values.size())
    {}


    std::vector<double>& get_values() {
        return values;
    }

    std::vector<double> get_values(const individual_index_t& index) {
        auto result = std::vector<double>(index.size());
        auto result_i = 0u;
        for (auto i : index) {
            result[result_i] = values[i];
            ++result_i;
        }
        return result;
    }

    void queue_update(
        const std::vector<double>& values,
        const std::vector<size_t>& index
    ) {
        if (values.size() > 1 && values.size() < size && values.size() != index.size()) {
            Rcpp::stop("Mismatch between value and index length");
        }
        for (auto i : index) {
            if (i < 0 || i >= size) {
                Rcpp::stop("Index out of bounds");
            }
        }
        updates.push({ values, index });
    }

    virtual void update() override {
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
                    to_update = std::vector<double>(size, values[0]);
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
};

#endif /* INST_INCLUDE_STATE_H_ */
