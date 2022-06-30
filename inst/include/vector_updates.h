/*
 * vector_updates.h
 *
 *  Created on: 30 Jun 2022
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_VECTOR_UPDATES_H_
#define INST_INCLUDE_VECTOR_UPDATES_H_

#include <vector>
#include "common_types.h"

template <class A>
class VectorExtendUpdate {
    const std::vector<A> new_values;
public:
    VectorExtendUpdate(const std::vector<A>& new_values)
        : new_values(new_values) {};
    void update(std::vector<A>& values) const {
        values.insert(values.end(), new_values.begin(), new_values.end());
    };
};

template <class A>
class VectorShrinkUpdate {
    std::vector<size_t> index;
public:
    VectorShrinkUpdate(const std::vector<size_t>& index) : index(index) {
        // sort
        std::sort(this->index.begin(), this->index.end());
        // deduplicate
        this->index.erase(
            std::unique(this->index.begin(), this->index.end()),
            this->index.end()
        );
    };
    VectorShrinkUpdate(const individual_index_t& index)
        : index(std::vector<size_t>(index.cbegin(), index.cend())) {};
    void update(std::vector<A>& values) const {
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
    };
};

#endif /* INST_INCLUDE_VECTOR_UPDATES_H_ */
