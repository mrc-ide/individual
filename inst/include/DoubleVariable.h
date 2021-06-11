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
#include <sstream>

struct DoubleVariable : public Variable {

    using update_t = std::pair<std::vector<double>, std::vector<size_t>>;
    std::queue<update_t> updates;
    size_t size;
    std::vector<double> values;

    DoubleVariable(const std::vector<double>& values)
        : size(values.size()), values(values)
    {}


    virtual std::vector<double>& get_values() {
        return values;
    }

    virtual std::vector<double> get_values(const individual_index_t& index) {
        auto result = std::vector<double>(index.size());
        auto result_i = 0u;
        for (auto i : index) {
            result[result_i] = values[i];
            ++result_i;
        }
        return result;
    }

    virtual std::vector<double> get_values(const std::vector<size_t>& index) {
        auto result = std::vector<double>(index.size());
        auto result_i = 0u;
        for (auto i : index) {
            result[result_i] = values.at(i);
            ++result_i;
        }
        return result;
    }

    // get indices of individuals whose value is in some [a,b]
    virtual individual_index_t get_index_of_range(
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

    // get indices of individuals whose value is in some [a,b]
    virtual size_t get_size_of_range(
        const double a, const double b
    ) const {
        
        size_t result = std::count_if(values.begin(), values.end(), [&](const double v) -> bool {
            return !(v < a) && !(b < v);
        });

        return result;

    }

    virtual void queue_update(
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

#endif /* INST_INCLUDE_DOUBLE_VARIABLE_H_ */
