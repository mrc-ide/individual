/*
 * vector_updates.h
 *
 *  Created on: 30 Jun 2022
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_CATEGORY_UPDATES_H_
#define INST_INCLUDE_CATEGORY_UPDATES_H_

#include "common_types.h"

class CategoricalExtendUpdate {
    const std::vector<std::string> values;
public:
    CategoricalExtendUpdate(const std::vector<std::string>& values) : values(values) {};
    void update(named_array_t<individual_index_t>& indices) const {
        const auto initial_size = indices.begin()->second.max_size();
        for (auto& entry : indices) {
            entry.second.extend(values.size());
        }
        for (auto i = 0u; i < values.size(); ++i) {
            indices.at(values[i]).insert(initial_size + i);
        }
    };
};

class CategoricalShrinkUpdate {
    std::vector<size_t> index;
public:
    CategoricalShrinkUpdate(const std::vector<size_t>& index) : index(index) {
        // sort
        std::sort(this->index.begin(), this->index.end());
        // deduplicate
        this->index.erase(
            std::unique(this->index.begin(), this->index.end()),
            this->index.end()
        );
    };
    CategoricalShrinkUpdate(const individual_index_t& index)
        : index(std::vector<size_t>(index.cbegin(), index.cend())) {};
    void update(named_array_t<individual_index_t>& indices) const {
        for (auto& entry : indices) {
            entry.second.shrink(index);
        }
    };
};

#endif /* INST_INCLUDE_CATEGORY_UPDATES_H_ */
