/*
 * ResizeableDoubleVariable.h
 *
 *  Created on: 11 Nov 2021
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_RESIZEABLE_DOUBLE_VARIABLE_H_
#define INST_INCLUDE_RESIZEABLE_DOUBLE_VARIABLE_H_

#include "Variable.h"
#include "common_types.h"
#include <Rcpp.h>
#include <queue>
#include <list>
#include <memory>
#include "utils.h"

struct ResizeableDoubleVariable;

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
    virtual ~VectorShrinkUpdate() = default;
};


//' @title a variable object for double precision floats
//' @description This class provides functionality for variables which takes values
//' in the real numbers. It inherits from Variable.
//' It contains the following data members:
//'     * updates: a priority queue of pairs of values and indices to update
//'     * values: a vector of values
struct ResizeableDoubleVariable : public Variable {

    using update_t = std::pair<std::vector<double>, std::vector<size_t>>;
    std::queue<update_t> updates;
    std::queue<std::function<void (std::list<double>&)>> resize_updates;
    std::list<double> values;
    
    ResizeableDoubleVariable(const std::vector<double>& values);
    virtual ~ResizeableDoubleVariable() = default;

    virtual std::list<double> get_values() const;
    virtual std::vector<double> get_values(const individual_index_t& index) const;
    virtual std::vector<double> get_values(const std::vector<size_t>& index) const;

    virtual individual_index_t get_index_of_range(const double a, const double b) const;
    virtual size_t get_size_of_range(const double a, const double b) const;

    virtual void queue_update(const std::vector<double>& values, const std::vector<size_t>& index);
    virtual void queue_extend(const std::vector<double>& values);
    virtual void queue_shrink(const std::vector<size_t>&);
    virtual void queue_shrink(const individual_index_t&);
    virtual size_t size() const;
    virtual void update() override;
};

inline ResizeableDoubleVariable::ResizeableDoubleVariable(
    const std::vector<double>& values
    ) : values(std::list<double>(std::begin(values), std::end(values)))
{}

//' @title get all values
inline std::list<double> ResizeableDoubleVariable::get_values() const {
    return values;
}

//' @title get values at index given by a bitset
inline std::vector<double> ResizeableDoubleVariable::get_values(const individual_index_t& index) const {
    if (size() != index.max_size()) {
        Rcpp::stop("incompatible size bitset used to get values from DoubleVariable");
    }
    auto it = FilterIterator<std::list<double>::const_iterator, individual_index_t::iterator, const double>(
        std::begin(values),
        std::end(values),
        index.begin(),
        index.end()
    );
    return std::vector<double>(it.begin(), it.end());
}

//' @title get values at index given by a vector
inline std::vector<double> ResizeableDoubleVariable::get_values(const std::vector<size_t>& index) const {
    auto it = FilterIterator<std::list<double>::const_iterator, std::vector<size_t>::const_iterator, const double>(
        std::begin(values),
        std::end(values),
        std::begin(index),
        std::end(index)
    );
    return std::vector<double>(it.begin(), it.end());
}

//' @title return bitset giving index of individuals whose value is in some range [a,b]
inline individual_index_t ResizeableDoubleVariable::get_index_of_range(
        const double a, const double b
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
inline size_t ResizeableDoubleVariable::get_size_of_range(
        const double a, const double b
) const {
    size_t result = std::count_if(
        values.cbegin(),
        values.cend(),
        [&](const double v) -> bool {
            return !(v < a) && !(b < v);
        }
    );
    return result;
}

//' @title queue a state update for some subset of individuals
inline void ResizeableDoubleVariable::queue_update(
    const std::vector<double>& values,
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
inline void ResizeableDoubleVariable::queue_extend(
    const std::vector<double>& new_values
) {
    auto update = ExtendUpdate<double>(new_values);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
inline void ResizeableDoubleVariable::queue_shrink(
    const individual_index_t& index 
) {
    if (index.max_size() != size()) {
        Rcpp::stop("Invalid bitset size for variable shrink");
    }
    auto update = BitsetShrinkUpdate<double>(index);
    resize_updates.push([=](auto& values) { update.update(values); });
}

//' @title queue values to be erased from the variable
inline void ResizeableDoubleVariable::queue_shrink(
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

//' @title apply all queued state updates in FIFO order
inline void ResizeableDoubleVariable::update() {
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
                to_update = std::list<double>(
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

inline size_t ResizeableDoubleVariable::size() const {
    return values.size();
}

#endif /* INST_INCLUDE_RESIZEABLE_DOUBLE_VARIABLE_H_ */
