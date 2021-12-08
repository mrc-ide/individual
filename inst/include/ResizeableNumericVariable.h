/*
 * ResizeableNumericVariable.h
 *
 *  Created on: 11 Nov 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_RESIZEABLE_NUMERIC_VARIABLE_H_
#define INST_INCLUDE_RESIZEABLE_NUMERIC_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>
#include <list>
#include <memory>
#include "utils.h"

template<class A>
struct ResizeableNumericVariable;

template<class A>
class ExtendUpdate {
    const std::vector<A> values;
public:
    ExtendUpdate(const std::vector<A>& values) : values(values) {};
    void update(std::list<A>& values) const {
        values.insert(
            std::end(values),
            std::cbegin(this->values),
            std::cend(this->values)
        );
    };
};

template<class A>
class BitsetShrinkUpdate {
    const individual_index_t index;
public:
    BitsetShrinkUpdate(const individual_index_t& index) : index(index) {};
    void update(std::list<A>& values) const {
        auto diffs = std::vector<size_t>(index.size());
        std::adjacent_difference(
            std::begin(index),
            std::end(index),
            std::begin(diffs)
        );
        auto it = std::begin(values);
        auto extra_step = 0u;
        for (auto d : diffs) {
            std::advance(it, d - extra_step);
            it = values.erase(it);
            extra_step = 1u;
        }
    };
};

template<class A>
class VectorShrinkUpdate {
    std::vector<size_t> index;
public:
    VectorShrinkUpdate(const std::vector<size_t>& index) : index(index) {
        std::sort(std::begin(this->index), std::end(this->index));
    };
    void update(std::list<A>& values) const {
        auto diffs = std::vector<size_t>(index.size());
        std::adjacent_difference(
            std::begin(index),
            std::end(index),
            std::begin(diffs)
        );
        auto it = std::begin(values);
        auto extra_step = 0u;
        for (auto d : diffs) {
            std::advance(it, d - extra_step);
            it = values.erase(it);
            extra_step = 1u;
        }
    };
};


//' @title a variable object for double precision floats
//' @description This class provides functionality for variables which takes values
//' in the real numbers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * values: a vector of values
template<class A>
struct ResizeableNumericVariable {

    using update_t = std::pair<std::vector<A>, std::vector<size_t>>;
    std::queue<update_t> updates;
    std::queue<std::function<void (std::list<A>&)>> resize_updates;
    std::list<A> values;
    
    ResizeableNumericVariable(const std::vector<A>& values);

    std::list<A> get_values() const;
    std::vector<A> get_values(const individual_index_t& index) const;
    std::vector<A> get_values(const std::vector<size_t>& index) const;

    individual_index_t get_index_of_range(const A a, const A b) const;
    size_t get_size_of_range(const A a, const A b) const;

    void queue_update(const std::vector<A>& values, const std::vector<size_t>& index);
    void queue_extend(const std::vector<A>& values);
    void queue_shrink(const std::vector<size_t>&);
    void queue_shrink(const individual_index_t&);
    size_t size() const;
    void update();
};

template<class A>
inline ResizeableNumericVariable<A>::ResizeableNumericVariable(
    const std::vector<A>& values
    ) : values(std::list<A>(std::begin(values), std::end(values)))
{}

//' @title get all values
template<class A>
inline std::list<A> ResizeableNumericVariable<A>::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
template<class A>
inline std::vector<A> ResizeableNumericVariable<A>::get_values(const individual_index_t& index) const {
    if (size() != index.max_size()) {
        Rcpp::stop("incompatible size bitset used to get values from Variable");
    }
    auto it = FilterIterator<typename std::list<A>::const_iterator, individual_index_t::iterator, const A>(
        std::begin(values),
        std::end(values),
        index.begin(),
        index.end()
    );
    return std::vector<A>(it.begin(), it.end());
}

//' @title get values at index given by a vector
template<class A>
inline std::vector<A> ResizeableNumericVariable<A>::get_values(const std::vector<size_t>& index) const {
    auto it = FilterIterator<typename std::list<A>::const_iterator, std::vector<size_t>::const_iterator, const A>(
        std::begin(values),
        std::end(values),
        std::begin(index),
        std::end(index)
    );
    return std::vector<A>(it.begin(), it.end());
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
template<class A>
inline individual_index_t ResizeableNumericVariable<A>::get_index_of_range(
        const A a, const A b
) const {
    auto result = individual_index_t(size());
    auto i = 0u;
    for (const auto& x : values) {
        if(!((x < a) || (b < x))) {
            result.insert(i);
        }
        ++i;
    }
    return result;
}

//' @title return number of individuals whose value is in some range [a,b]
template<class A>
inline size_t ResizeableNumericVariable<A>::get_size_of_range(
        const A a, const A b
) const {
    size_t result = std::count_if(
        values.cbegin(),
        values.cend(),
        [&](const A v) -> bool {
            return !(v < a) && !(b < v);
        }
    );
    return result;
}

//' @title queue a state update for some subset of individuals
template<class A>
inline void ResizeableNumericVariable<A>::queue_update(
    const std::vector<A>& values,
    const std::vector<size_t>& index
) {
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

//' @title queue new values to add to the variable
template<class A>
inline void ResizeableNumericVariable<A>::queue_extend(
    const std::vector<A>& new_values
) {
    auto update = ExtendUpdate<A>(new_values);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
template<class A>
inline void ResizeableNumericVariable<A>::queue_shrink(
    const individual_index_t& index 
) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    auto update = BitsetShrinkUpdate<A>(index);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
template<class A>
inline void ResizeableNumericVariable<A>::queue_shrink(
    const std::vector<size_t>& index
) {
    for (const auto& x : index) {
        if (x >= size()) {
            Rcpp::stop("Invalid vector index for variable shrink");
        }
    }
    auto update = VectorShrinkUpdate<A>(index);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title apply all queued state updates in FIFO order
template<class A>
inline void ResizeableNumericVariable<A>::update() {
    while(updates.size() > 0) {
        auto& update = updates.front();
        const auto& values = update.first;
        auto& index = update.second;
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
                to_update = std::list<A>(
                    std::cbegin(values),
                    std::cend(values)
                );
            }
        } else {
            std::sort(std::begin(index), std::end(index));
            auto diffs = std::vector<size_t>(index.size());
            std::adjacent_difference(
                std::begin(index),
                std::end(index),
                std::begin(diffs)
            );
            auto update_iterator = std::begin(to_update);
            if (value_fill) {
                // For a fill update
                for (auto d : diffs) {
                    std::advance(update_iterator, d);
                    *update_iterator = values[0];
                }
            } else {
                // Subset assignment
                auto i = 0u;
                for (auto d : diffs) {
                    std::advance(update_iterator, d);
                    *update_iterator = values[i];
                    ++i;
                }
            }
        }
        updates.pop();
    }

    // handle resize updates
    while(resize_updates.size() > 0) {
        const auto& update = resize_updates.front();
        update(values);
        resize_updates.pop();
    }
}

template<class A>
inline size_t ResizeableNumericVariable<A>::size() const {
    return values.size();
}

#endif /* INST_INCLUDE_RESIZEABLE_NUMERIC_VARIABLE_H_ */
