/*
 * IndividualIndex.h
 *
 *  Created on: 1 Jun 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_INDIVIDUALINDEX_H_
#define INST_INCLUDE_INDIVIDUALINDEX_H_

#include <Rcpp.h>

class IndividualIndex;

using individual_index_t = IndividualIndex;

class IndividualIndex {
private:
    std::vector<bool> existence;
    size_t n;
    size_t first() const;
public:
    using allocator_type = std::allocator<size_t>;
    using value_type = allocator_type::value_type;
    using reference = allocator_type::reference;
    using const_reference = allocator_type::const_reference;
    using difference_type = allocator_type::difference_type;
    using size_type = allocator_type::size_type;
    using input_iterator_type = std::iterator<std::input_iterator_tag, size_t>;

    class const_iterator {
    private:
        const IndividualIndex& index;
        size_t pos;
    public:
        using difference_type = allocator_type::difference_type;
        using value_type = allocator_type::value_type;
        using reference = const allocator_type::reference;
        using pointer = const allocator_type::pointer;
        using iterator_category = std::forward_iterator_tag;

        const_iterator(const IndividualIndex&, size_t);

        bool operator==(const const_iterator&) const;
        bool operator!=(const const_iterator&) const;

        const_iterator& operator++();

        reference operator*();
    };

    using iterator = const_iterator;

    IndividualIndex(size_t);
    template<class InputIterator>
    IndividualIndex(size_t, InputIterator, InputIterator);
    bool operator==(const IndividualIndex&) const;
    bool operator!=(const IndividualIndex&) const;
    iterator begin();
    const_iterator begin() const;
    const_iterator cbegin() const;
    iterator end();
    const_iterator end() const;
    const_iterator cend() const;
    void erase(size_t);
    iterator find(size_t);
    template<class InputIterator>
    void insert(InputIterator, InputIterator);
    void insert(size_t);
    size_type size() const;
    size_type max_size() const;
    bool empty() const;
};

inline IndividualIndex::const_iterator::const_iterator(
    const IndividualIndex& index,
    size_t pos) : index(index), pos(pos) {}

inline bool IndividualIndex::const_iterator::operator ==(
    const const_iterator& other) const {
    return index.existence == other.index.existence && pos == other.pos;
}

inline bool IndividualIndex::const_iterator::operator !=(
    const const_iterator& other) const {
    return index.existence != other.index.existence || pos != other.pos;
}

inline IndividualIndex::const_iterator& IndividualIndex::const_iterator::operator ++() {
    ++pos;
    while(pos < index.existence.size() && !index.existence[pos]) {
        ++pos;
    }
    return *this;
}

inline IndividualIndex::const_iterator::reference IndividualIndex::const_iterator::operator *() {
    return pos;
}

inline IndividualIndex::IndividualIndex(size_t size) {
    existence = std::vector<bool>(size, false);
    n = 0;
}


template<class InputIterator>
inline IndividualIndex::IndividualIndex(size_t size, InputIterator begin, InputIterator end) {
    existence = std::vector<bool>(size, false);
    n = 0;
    insert(begin, end);
}

inline bool IndividualIndex::operator ==(const IndividualIndex&) const {
    Rcpp::stop("== Not implemented");
    return false;
}

inline bool IndividualIndex::operator !=(const IndividualIndex&) const {
    Rcpp::stop("!= Not implemented");
    return false;
}

inline size_t IndividualIndex::first() const {
    if (n == 0) {
        return existence.size();
    }
    auto pos = 0u;
    while(!existence[pos]) {
        ++pos;
    }
    return pos;
}

inline IndividualIndex::iterator IndividualIndex::begin() {
    return IndividualIndex::iterator(*this, first());
}

inline IndividualIndex::const_iterator IndividualIndex::begin() const {
    return IndividualIndex::const_iterator(*this, first());
}

inline IndividualIndex::const_iterator IndividualIndex::cbegin() const {
    return IndividualIndex::const_iterator(*this, first());
}

inline IndividualIndex::iterator IndividualIndex::end() {
    return IndividualIndex::iterator(*this, existence.size());
}

inline IndividualIndex::const_iterator IndividualIndex::end() const {
    return IndividualIndex::const_iterator(*this, existence.size());
}

inline IndividualIndex::const_iterator IndividualIndex::cend() const {
    return IndividualIndex::const_iterator(*this, existence.size());
}

inline void IndividualIndex::erase(size_t v) {
    if (existence[v]) {
        existence[v] = false;
        n--;
    }
}

inline IndividualIndex::iterator IndividualIndex::find(size_t v) {
    if(existence[v]) {
        return IndividualIndex::iterator(*this, v);
    }
    return end();
}

template<class InputIterator>
inline void IndividualIndex::insert(InputIterator begin, InputIterator end) {
    auto it = begin;
    while (it != end) {
        insert(*it);
        ++it;
    }
}

inline void IndividualIndex::insert(size_t v) {
    if (!existence[v]) {
        existence[v] = true;
        n++;
    }
}

inline IndividualIndex::size_type IndividualIndex::size() const {
    return n;
}

inline IndividualIndex::size_type IndividualIndex::max_size() const {
    return n;
}

inline bool IndividualIndex::empty() const {
    return n == 0;
}

#endif /* INST_INCLUDE_INDIVIDUALINDEX_H_ */
